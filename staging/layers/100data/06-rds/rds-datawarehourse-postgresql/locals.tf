locals {
  app                   = "datawarehouse"
  engine_version        = "18.2"
  multi_az              = true
  db_instance_type      = "db.t4g.micro"
  storage_type          = "gp3"
  allocated_storage     = 20
  max_allocated_storage = 100
  repository            = "abex-aws-env-staging"
  tf_state_bucket       = "abaxx-exch-tf-state-nonprod"
  region_parts  = split("-", data.aws_region.current.name)
  region_prefix = join("", [local.region_parts[0], substr(local.region_parts[1], 0, 1), local.region_parts[2]])
  db_identifier = "abex-${local.app}-${local.region_prefix}-${local.env}"

  additional_parameters = []

  additional_ingress_with_cidr_blocks = []
}
