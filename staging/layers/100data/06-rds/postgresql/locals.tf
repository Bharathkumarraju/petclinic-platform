locals {
  tags = {
    env               = local.env
    map-migrated      = "mig46499"
    rds-backup-plan-1 = "true"
  }

  cloudwatch_tags = {
    env          = local.env
    ExportToS3   = true
    purpose      = "Track RDS Proxy usage"
    map-migrated = "mig46499"
  }
  private_access_only = [
    {
      description = "Client access to Clara DB"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    }
  ]
  cloudwatch_logs_encrypt_key            = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  cloudwatch_log_group_retention_in_days = 90
  region                                 = local.region_map["sin"]
  region_parts                           = split("-", local.region)
  region_prefix                          = join("", [local.region_parts[0], substr(local.region_parts[1], 0, 1), local.region_parts[2]])
  claradb_instance_type                  = "db.t4g.medium"
  claradb_num_of_instances               = 2
  domain                                 = "xabx.net"
  availability_zones                     = slice(sort(data.aws_availability_zones.all.names), 0, 3)
  exchangedba_username                   = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.exchangedba_creds.secret_string)["username"])
  exchangedba_password                   = jsondecode(data.aws_secretsmanager_secret_version.exchangedba_creds.secret_string)["password"]
  client_cidr_range                      = "172.23.0.0/16"
  aws_infra_private_cidr_range           = "172.21.1.0/24"
  dms_replication_cidr_range             = "10.40.6.0/24"
  iam_auth                               = "REQUIRED"
  require_tls                            = true
  create_proxy                           = "true"
  engine_family                          = "MYSQL"
  target_db_cluster                      = "true"
  sns_topic                              = "arn:aws:sns:ap-southeast-1:${local.account_id}:alerts-slack-${local.env}-sin"
}
