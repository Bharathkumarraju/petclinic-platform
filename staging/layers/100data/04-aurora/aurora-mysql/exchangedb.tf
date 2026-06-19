locals {
  db_prefix    = "exchange"
  db_id_prefix = "${local.db_prefix}-${local.region_prefix}-${local.env}"
}

# module "exchangedb_old" {
#   source               = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//rds-aurora-apps?ref=fix/rds-aurora-apps"
#   env                  = local.env
#   create               = true
#   putin_khuylo         = true
#   db_prefix            = local.db_prefix
#   name                 = "${local.db_prefix}-${local.region_prefix}-${local.env}-old"
#   region_prefix        = local.region_prefix
#   db_subnet_group_name = data.terraform_remote_state.network.outputs.main_vpc_db_subnet_group_name_sin
#   instances = {
#     1 = {
#       instance_class      = local.claradb_instance_type
#       publicly_accessible = false
#     }
#     2 = {
#       instance_class      = local.claradb_instance_type
#       publicly_accessible = false
#     }
#   }
#   create_monitoring_role = true

#   manage_master_user_password           = false
#   engine                                = "aurora-mysql"
#   engine_version                        = "8.0.mysql_aurora.3.10.3" # aws rds describe-db-engine-versions --engine aurora-mysql --engine-version 8.0 --version 8.0.mysql_aurora.3.05.2 <- change accordingly to view valid upgrade targets
#   db_cluster_parameter_group_family     = "aurora-mysql8.0"
#   port                                  = 3306
#   create_db_cluster_parameter_group     = true
#   create_db_subnet_group                = false
#   apply_immediately                     = true
#   skip_final_snapshot                   = true
#   iam_database_authentication_enabled   = false
#   kms_key_id                            = data.aws_kms_key.rds_kms_key.arn
#   iam_role_name                         = local.db_prefix
#   monitoring_interval                   = 30
#   performance_insights_enabled          = true
#   performance_insights_retention_period = 7
#   performance_insights_kms_key_id       = local.cloudwatch_logs_encrypt_key
#   cloudwatch_log_group_kms_key_id       = local.cloudwatch_logs_encrypt_key
#   master_username                       = local.exchangedba_username
#   master_password                       = local.exchangedba_password
#   rds_security_group_id                 = [module.rds_sg.security_group_id]
#   ca_cert_identifier                    = "rds-ca-rsa4096-g1"
#   enabled_cloudwatch_logs_exports       = ["general", "audit", "error", "slowquery"]
#   create_cloudwatch_log_group           = false
#   db_cluster_parameter_group_parameters = [
#     {
#       name         = "connect_timeout"
#       value        = 120
#       apply_method = "immediate"
#       }, {
#       name         = "innodb_lock_wait_timeout"
#       value        = 300
#       apply_method = "immediate"
#       }, {
#       name         = "log_output"
#       value        = "FILE"
#       apply_method = "immediate"
#       }, {
#       name         = "max_allowed_packet"
#       value        = "67108864"
#       apply_method = "immediate"
#       }, {
#       name         = "aurora_parallel_query"
#       value        = "0"
#       apply_method = "pending-reboot"
#       }, {
#       name         = "binlog_format"
#       value        = "ROW"
#       apply_method = "pending-reboot"
#       }, {
#       name         = "log_bin_trust_function_creators"
#       value        = 1
#       apply_method = "immediate"
#       }, {
#       name         = "require_secure_transport"
#       value        = "OFF"
#       apply_method = "immediate"
#       }, {
#       name         = "server_audit_logging"
#       value        = 1
#       apply_method = "immediate"
#       }, {
#       name         = "server_audit_incl_users"
#       value        = "clarityapp"
#       apply_method = "immediate"
#       }, {
#       name         = "server_audit_events"
#       value        = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
#       apply_method = "immediate"
#       }, {
#       name         = "general_log"
#       value        = 1
#       apply_method = "immediate"
#     }
#   ]
#   db_parameter_group_parameters = [
#     {
#       name         = "connect_timeout"
#       value        = 60
#       apply_method = "immediate"
#       }, {
#       name         = "general_log"
#       value        = 1
#       apply_method = "immediate"
#       }, {
#       name         = "innodb_lock_wait_timeout"
#       value        = 300
#       apply_method = "immediate"
#       }, {
#       name         = "log_output"
#       value        = "FILE"
#       apply_method = "pending-reboot"
#       }, {
#       name         = "long_query_time"
#       value        = 5
#       apply_method = "immediate"
#       }, {
#       name         = "max_connections"
#       value        = 2000
#       apply_method = "immediate"
#       }, {
#       name         = "slow_query_log"
#       value        = 1
#       apply_method = "immediate"
#       }, {
#       name         = "log_bin_trust_function_creators"
#       value        = 1
#       apply_method = "immediate"
#     }
#   ]
# }

module "exchangedb" {
  source               = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//rds-aurora-apps"
  env                  = local.env
  create               = true
  putin_khuylo         = true
  db_prefix            = local.db_prefix
  name                 = "${local.db_prefix}-${local.region_prefix}-${local.env}"
  region_prefix        = local.region_prefix
  db_subnet_group_name = data.terraform_remote_state.network.outputs.main_vpc_db_subnet_group_name_sin

  backtrack_window       = 72 * 3600
  snapshot_identifier    = "acsv7-1-exchange-aps1-staging"
  create_monitoring_role = true
  instances = {
    1 = {
      instance_class      = local.claradb_instance_type
      publicly_accessible = false
    }
    2 = {
      instance_class      = local.claradb_instance_type
      publicly_accessible = false
    }
  }
  manage_master_user_password           = false
  engine                                = "aurora-mysql"
  engine_version                        = "8.0.mysql_aurora.3.10.3" # aws rds describe-db-engine-versions --engine aurora-mysql --engine-version 8.0 --version 8.0.mysql_aurora.3.05.2 <- change accordingly to view valid upgrade targets
  db_cluster_parameter_group_family     = "aurora-mysql8.0"
  port                                  = 3306
  create_db_cluster_parameter_group     = true
  create_db_subnet_group                = false
  apply_immediately                     = true
  skip_final_snapshot                   = true
  iam_database_authentication_enabled   = false
  kms_key_id                            = data.aws_kms_key.rds_kms_key.arn
  iam_role_name                         = "${local.db_prefix}-rds-monitoring-role"
  monitoring_interval                   = 30
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = local.cloudwatch_logs_encrypt_key
  cloudwatch_log_group_kms_key_id       = local.cloudwatch_logs_encrypt_key
  master_username                       = local.exchangedba_username
  master_password                       = local.exchangedba_password
  rds_security_group_id                 = [module.rds_sg.security_group_id]
  ca_cert_identifier                    = "rds-ca-rsa4096-g1"
  enabled_cloudwatch_logs_exports       = ["general", "audit", "error", "slowquery"]
  create_cloudwatch_log_group           = false
  db_cluster_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 120
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
      }, {
      name         = "max_allowed_packet"
      value        = "67108864"
      apply_method = "immediate"
      }, {
      name         = "aurora_parallel_query"
      value        = "0"
      apply_method = "pending-reboot"
      }, {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "require_secure_transport"
      value        = "OFF"
      apply_method = "immediate"
      }, {
      name         = "server_audit_logging"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "server_audit_incl_users"
      value        = "clarityapp"
      apply_method = "immediate"
      }, {
      name         = "server_audit_events"
      value        = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
      apply_method = "immediate"
      }, {
      name         = "general_log"
      value        = 1
      apply_method = "immediate"
    }
  ]
  db_parameter_group_parameters = [
    {
      name         = "connect_timeout"
      value        = 60
      apply_method = "immediate"
      }, {
      name         = "general_log"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "innodb_lock_wait_timeout"
      value        = 300
      apply_method = "immediate"
      }, {
      name         = "log_output"
      value        = "FILE"
      apply_method = "pending-reboot"
      }, {
      name         = "long_query_time"
      value        = 5
      apply_method = "immediate"
      }, {
      name         = "max_connections"
      value        = 2000
      apply_method = "immediate"
      }, {
      name         = "slow_query_log"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "log_bin_trust_function_creators"
      value        = 1
      apply_method = "immediate"
    }
  ]
}

import {
  to = module.exchangedb.aws_rds_cluster_parameter_group.this[0]
  id = "exchange-aps1-staging-cpg20260423013532912300000001"
}

import {
  to = module.exchangedb.aws_iam_role.rds_enhanced_monitoring[0]
  id = "exchange-rds-monitoring-role"
}

removed {
  from = module.exchangedb_restored.aws_rds_cluster_parameter_group.this
  lifecycle {
    destroy = false
  }
}

module "claradb-rds-proxy" {
  source                      = "terraform-aws-modules/rds-proxy/aws"
  version                     = "2.1.2"
  name                        = "${local.db_prefix}-${local.region_prefix}-proxy-${local.env}"
  iam_auth                    = local.iam_auth
  vpc_subnet_ids              = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  vpc_security_group_ids      = [module.rds_proxy_sg.security_group_id]
  create_proxy                = local.create_proxy
  require_tls                 = local.require_tls
  engine_family               = local.engine_family
  debug_logging               = false # Manually update this to true to enable debug logging, it will turn off automatically after 24 hours
  target_db_cluster           = local.target_db_cluster
  db_cluster_identifier       = module.exchangedb.cluster_id
  log_group_kms_key_id        = local.cloudwatch_logs_encrypt_key
  log_group_retention_in_days = 90
  log_group_tags              = local.cloudwatch_tags

  db_proxy_endpoints = {
    read_write = {
      name                   = replace("${local.db_id_prefix}-rw-endpoint", ".", "-")
      vpc_subnet_ids         = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
      vpc_security_group_ids = [module.rds_proxy_sg.security_group_id]
      tags                   = local.tags
    },
    read_only = {
      name                   = replace("${local.db_id_prefix}-r-endpoint", ".", "-")
      vpc_subnet_ids         = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
      vpc_security_group_ids = [module.rds_proxy_sg.security_group_id]
      target_role            = "READ_ONLY"
      tags                   = local.tags
    }
  }

  secrets = {
    (local.exchangedba_username) = {
      description = data.aws_secretsmanager_secret.exchangedba_creds.description
      arn         = data.aws_secretsmanager_secret.exchangedba_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.exchangeviewer_username) = {
      description = data.aws_secretsmanager_secret.exchangeviewer_creds.description
      arn         = data.aws_secretsmanager_secret.exchangeviewer_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.clarity_username) = {
      description = data.aws_secretsmanager_secret.clarity_db_creds.description
      arn         = data.aws_secretsmanager_secret.clarity_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.keycloak_username) = {
      description = data.aws_secretsmanager_secret.keycloak_creds.description
      arn         = data.aws_secretsmanager_secret.keycloak_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.eprime_username) = {
      description = data.aws_secretsmanager_secret.eprime-db-creds.description
      arn         = data.aws_secretsmanager_secret.eprime-db-creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.mdapp_username) = {
      description = data.aws_secretsmanager_secret.mdapp_creds.description
      arn         = data.aws_secretsmanager_secret.mdapp_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.mmtapp_username) = {
      description = data.aws_secretsmanager_secret.mmtapp_creds.description
      arn         = data.aws_secretsmanager_secret.mmtapp_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.mmtdba_username) = {
      description = data.aws_secretsmanager_secret.mmtdba_creds.description
      arn         = data.aws_secretsmanager_secret.mmtdba_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.mmtviewer_username) = {
      description = data.aws_secretsmanager_secret.mmtviewer_creds.description
      arn         = data.aws_secretsmanager_secret.mmtviewer_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.mdviewer_username) = {
      description = data.aws_secretsmanager_secret.mdviewer_creds.description
      arn         = data.aws_secretsmanager_secret.mdviewer_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.dspupdateapp_username) = {
      description = data.aws_secretsmanager_secret.dspupdateapp_creds.description
      arn         = data.aws_secretsmanager_secret.dspupdateapp_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.authx_username) = {
      description = data.aws_secretsmanager_secret.authx_db_creds.description
      arn         = data.aws_secretsmanager_secret.authx_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.authx_web_username) = {
      description = data.aws_secretsmanager_secret.authx_web_db_creds.description
      arn         = data.aws_secretsmanager_secret.authx_web_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.clapi_username) = {
      description = data.aws_secretsmanager_secret.clapi_db_creds.description
      arn         = data.aws_secretsmanager_secret.clapi_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.alert_username) = {
      description = data.aws_secretsmanager_secret.alert_db_creds.description
      arn         = data.aws_secretsmanager_secret.alert_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.clara_username) = {
      description = data.aws_secretsmanager_secret.clara_db_creds.description
      arn         = data.aws_secretsmanager_secret.clara_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.claus_username) = {
      description = data.aws_secretsmanager_secret.claus_db_creds.description
      arn         = data.aws_secretsmanager_secret.claus_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.clic_username) = {
      description = data.aws_secretsmanager_secret.clic_db_creds.description
      arn         = data.aws_secretsmanager_secret.clic_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.cloc_username) = {
      description = data.aws_secretsmanager_secret.cloc_db_creds.description
      arn         = data.aws_secretsmanager_secret.cloc_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.coco_username) = {
      description = data.aws_secretsmanager_secret.coco_db_creds.description
      arn         = data.aws_secretsmanager_secret.coco_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.tcexberry_username) = {
      description = data.aws_secretsmanager_secret.tcexberry_db_creds.description
      arn         = data.aws_secretsmanager_secret.tcexberry_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
    (local.claraviewer_username) = {
      description = data.aws_secretsmanager_secret.claraviewer_db_creds.description
      arn         = data.aws_secretsmanager_secret.claraviewer_db_creds.arn
      kms_key_id  = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
    }
  }
  tags = local.tags
}


module "rds_proxy_sg" {

  source                 = "terraform-aws-modules/security-group/aws"
  version                = "5.3.0"
  name                   = "${local.db_prefix}-proxy-sg"
  description            = "Clara DB Security Group"
  vpc_id                 = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  revoke_rules_on_delete = true
  ingress_with_cidr_blocks = [
    {
      description = "Client access to Clara DB"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      description = "Clara DB VPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.client_cidr_range
    },
    {
      description = "Clara DB OpenVPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.network_dev_cidr_range
    },
    {
      description = "Clara DB AWS-Infra access"
      rule        = "mysql-tcp"
      cidr_blocks = local.aws_infra_private_cidr_range
    }
  ]
  egress_with_cidr_blocks = [
    {
      description = "Clara DB subnet access"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_db_subnets_cidr_blocks_sin)
    },
    {
      description = "Clara DB VPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.client_cidr_range
    },
    {
      description = "Clara DB OpenVPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.network_dev_cidr_range
    },
    {
      description = "Clara DB AWS-Infra access"
      rule        = "mysql-tcp"
      cidr_blocks = local.aws_infra_private_cidr_range
    }
  ]
  tags = local.tags
}
module "rds_sg" {
  source                 = "terraform-aws-modules/security-group/aws"
  version                = "5.3.0"
  name                   = "${local.db_prefix}-sg"
  description            = "Security Group for the Database"
  vpc_id                 = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  revoke_rules_on_delete = true
  ingress_with_cidr_blocks = [
    {
      description = "Client access to Clara DB"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      description = "DB Within VPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.client_cidr_range
    },
    {
      description = "Access for DMS Replication Instance"
      rule        = "mysql-tcp"
      cidr_blocks = local.dms_replication_cidr_range
    },
    {
      description = "DB Within OPENVPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.network_dev_cidr_range
    }
  ]
  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.rds_proxy_sg.security_group_id
  }]
  tags = local.tags
}

# Subscribe to Slack Alerts SNS
resource "aws_db_event_subscription" "slack" {
  name        = "${module.exchangedb.cluster_id}-sns-slack"
  sns_topic   = local.sns_topic
  source_type = "db-cluster"
  source_ids  = [module.exchangedb.cluster_id]
  // Muted to enable all event categories
  # event_categories = [
  #   "availability",
  #   "deletion",
  #   "failover",
  #   "failure",
  #   "low storage",
  #   "maintenance",
  #   "notification",
  #   "read replica",
  #   "recovery",
  #   "restoration",
  #   "backup",
  #   "configuration change",
  #   "security",
  #   "security patching",
  #   "creation",
  #   "backtrack"
  # ]

  tags = local.tags
}

resource "aws_db_event_subscription" "instance" {
  for_each    = module.exchangedb.cluster_members
  name        = "${each.value}-sns-slack"
  sns_topic   = local.sns_topic
  source_type = "db-instance"
  source_ids  = [each.value]

  tags = local.tags
}
