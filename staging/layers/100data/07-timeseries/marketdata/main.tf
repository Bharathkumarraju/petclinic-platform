module "marketdata" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//timestream//influxdb"

  env                                 = local.env
  db_prefix                           = local.db_prefix
  allocated_storage                   = local.allocated_storage
  additional_ingress_with_cidr_blocks = local.additional_ingress_with_cidr_blocks
  influxdb_instance_type              = local.influxdb_instance_type
  deployment_type                     = local.deployment_type
  bucket_log_name                     = local.bucket_log_name
  # tfstate_bucket                      = local.tf_state_bucket
}

