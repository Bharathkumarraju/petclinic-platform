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
  exchangeviewer_username                = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.exchangeviewer_creds.secret_string)["username"])
  clarity_username                       = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.clarity_db_creds.secret_string)["username"])
  authx_username                         = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.authx_db_creds.secret_string)["username"])
  authx_web_username                     = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.authx_web_db_creds.secret_string)["username"])
  clapi_username                         = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.clapi_db_creds.secret_string)["username"])
  clara_username                         = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.clara_db_creds.secret_string)["username"])
  claus_username                         = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.claus_db_creds.secret_string)["username"])
  clic_username                          = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.clic_db_creds.secret_string)["username"])
  cloc_username                          = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.cloc_db_creds.secret_string)["username"])
  coco_username                          = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.coco_db_creds.secret_string)["username"])
  tcexberry_username                     = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.tcexberry_db_creds.secret_string)["username"])
  keycloak_username                      = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.keycloak_creds.secret_string)["username"])
  eprime_username                        = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.eprime-db-creds.secret_string)["username"])
  mdapp_username                         = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.mdapp_creds.secret_string)["username"])
  mmtapp_username                        = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.mmtapp_creds.secret_string)["username"])
  mmtdba_username                        = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.mmtdba_creds.secret_string)["username"])
  mmtviewer_username                     = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.mmtviewer_creds.secret_string)["username"])
  mdviewer_username                      = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.mdviewer_creds.secret_string)["username"])
  claraviewer_username                   = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.claraviewer_db_creds.secret_string)["username"])
  dspupdateapp_username                  = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.dspupdateapp_creds.secret_string)["username"])
  alert_username                         = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.alert_db_creds.secret_string)["username"])
  client_cidr_range                      = "172.23.0.0/16"
  network_dev_cidr_range                 = "172.24.0.0/21"
  aws_infra_private_cidr_range           = "172.21.1.0/24"
  dms_replication_cidr_range             = "10.40.6.0/24"
  iam_auth                               = "REQUIRED"
  require_tls                            = true
  create_proxy                           = "true"
  engine_family                          = "MYSQL"
  target_db_cluster                      = "true"
  sns_topic                              = "arn:aws:sns:ap-southeast-1:${local.account_id}:alerts-slack-${local.env}-sin"
}
