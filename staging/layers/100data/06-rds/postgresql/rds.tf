locals {
  db_prefix     = "sharedpsql"
  db_identifier = "${local.db_prefix}-${local.region_prefix}-${local.env}"
}

module "postgres" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.db_identifier

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                   = "postgres"
  engine_version           = "17"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres17" # DB parameter group
  major_engine_version     = "17"         # DB option group
  instance_class           = "db.t4g.small"

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = local.db_prefix
  username = "sharedpsqldba"
  port     = 5432

  # Setting manage_master_user_password_rotation to false after it
  # has previously been set to true disables automatic rotation
  # however using an initial value of false (default) does not disable
  # automatic rotation and rotation will be handled by RDS.
  # manage_master_user_password_rotation allows users to configure
  # a non-default schedule and is not meant to disable rotation
  # when initially creating / enabling the password management feature
  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(15 days)"
  master_user_secret_kms_key_id                     = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
  kms_key_id                                        = data.aws_kms_key.rds_kms_key.arn
  multi_az                                          = true
  db_subnet_group_name                              = data.terraform_remote_state.network.outputs.main_vpc_db_subnet_group_name_sin
  vpc_security_group_ids                            = [module.security_group.security_group_id]
  iam_database_authentication_enabled               = true
  maintenance_window                                = "Mon:00:00-Mon:03:00"
  backup_window                                     = "22:00-00:00"
  enabled_cloudwatch_logs_exports                   = ["postgresql", "upgrade"]
  create_cloudwatch_log_group                       = false

  skip_final_snapshot = false
  deletion_protection = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = local.db_identifier
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Role for enhanced monitoring for ${local.db_identifier}"
  cloudwatch_log_group_kms_key_id       = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  performance_insights_kms_key_id       = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    },
    {
      apply_method = "pending-reboot"
      name         = "shared_preload_libraries"
      value        = "pgaudit,pg_stat_statements,pg_tle"
    },
    {
      name  = "pgaudit.log"
      value = "all"
    },
    {
      name  = "pgaudit.log_statement_once"
      value = 0
    },
    {
      name  = "pgaudit.log_parameter"
      value = 1
    },
    {
      name  = "pgaudit.log_catalog"
      value = 1
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  cloudwatch_log_group_tags = {
    "Sensitive" = "high"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name                   = "${local.db_identifier}-sg"
  description            = "Security Group for the ${local.db_identifier} database"
  vpc_id                 = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  revoke_rules_on_delete = true

  # ingress
  ingress_with_cidr_blocks = [
    {
      description = "Client access to db"
      rule        = "postgresql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      description = "DB Within VPN access"
      rule        = "postgresql-tcp"
      cidr_blocks = local.client_cidr_range
    },
    {
      description = "Atlantis access to db"
      rule        = "postgresql-tcp"
      cidr_blocks = "172.21.0.0/21"
    }
  ]

  # ingress_with_source_security_group_id = [
  #   {
  #     rule                     = "mysql-tcp"
  #     source_security_group_id = module.rds_proxy_sg.security_group_id
  # }]
  tags = local.tags
}

module "postgres_db_roles" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/postgres-root-controller"

  databases = {
    edge     = {}
    clearing = {}
  }


  master_username = module.postgres.db_instance_username
}

# # Subscribe to Slack Alerts SNS
# resource "aws_db_event_subscription" "slack" {
#   name        = "${module.exchangedb.cluster_id}-sns-slack"
#   sns_topic   = local.sns_topic
#   source_type = "db-cluster"
#   source_ids  = [module.exchangedb.cluster_id]
#   // Muted to enable all event categories
#   # event_categories = [
#   #   "availability",
#   #   "deletion",
#   #   "failover",
#   #   "failure",
#   #   "low storage",
#   #   "maintenance",
#   #   "notification",
#   #   "read replica",
#   #   "recovery",
#   #   "restoration",
#   #   "backup",
#   #   "configuration change",
#   #   "security",
#   #   "security patching",
#   #   "creation",
#   #   "backtrack"
#   # ]

#   tags = local.tags
# }

# resource "aws_db_event_subscription" "instance" {
#   for_each    = module.exchangedb.cluster_members
#   name        = "${each.value}-sns-slack"
#   sns_topic   = local.sns_topic
#   source_type = "db-instance"
#   source_ids  = [each.value]

#   tags = local.tags
# }
