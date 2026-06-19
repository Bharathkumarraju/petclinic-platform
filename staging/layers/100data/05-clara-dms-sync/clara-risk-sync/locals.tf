
locals {
  tags = {
    env          = local.env
    map-migrated = "mig46499"
  }
  source_cluster               = "exchange-aps1-staging-1.c44gvwoi9fu4.ap-southeast-1.rds.amazonaws.com"
  source_port                  = 3306
  source_type                  = "aurora"
  target_cluster               = "riskdb-aps1-staging-risk-1.c44gvwoi9fu4.ap-southeast-1.rds.amazonaws.com"
  target_port                  = 3306
  target_type                  = "aurora"
  client_cidr_range            = "172.23.0.0/16"
  aws_infra_private_cidr_range = "172.21.1.0/24"
}
