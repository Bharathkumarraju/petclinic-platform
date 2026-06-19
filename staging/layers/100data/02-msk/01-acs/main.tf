module "acs_kafka" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/msk"

  env = local.env

  msk_name                        = local.msk_name
  kafka_version                   = local.kafka_version
  num_broker_per_zone             = local.num_broker_per_zone
  instance_type                   = local.instance_type
  broker_min_volume_size          = local.broker_min_volume_size
  broker_max_volume_size          = local.broker_max_volume_size
  additional_security_group_rules = local.additional_security_group_rules
  msk_configuration_properties    = local.msk_configuration_properties
}
