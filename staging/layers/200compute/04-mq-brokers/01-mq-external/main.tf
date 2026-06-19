module "mq_external" {
  source = "./modules"

  env            = local.env
  broker_prefix  = local.broker_prefix
  engine_version = local.engine_version
  instance_type  = local.instance_type

  mq_configuration_data = local.mq_configuration_data

  nlb_tls_certificate_arn = local.nlb_tls_certificate_arn

  mq_users = local.mq_users
}

