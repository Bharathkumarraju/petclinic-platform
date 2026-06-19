module "exchange" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/activemq-brokers"

  env                         = local.env
  prefix                      = "ab.exc"
  region_prefix               = local.region_prefix
  host_instance_type          = "mq.t3.micro"
  external_mq_engine_version  = "5.18"                        # July 29, 2024 release
  internal_mq_engine_version  = "5.18"                        # match existing version
  external_mq_security_groups = [local.mq_internal_sg_id_sin] # internal sg for private subnets
  internal_mq_security_groups = [local.mq_internal_sg_id_sin]
  private_subnets             = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  ## MQ Configuration
  internal_mq_configuration_id       = aws_mq_configuration.internal.id
  internal_mq_configuration_revision = aws_mq_configuration.internal.latest_revision
  external_mq_configuration_id       = aws_mq_configuration.external.id
  external_mq_configuration_revision = aws_mq_configuration.external.latest_revision
}

resource "aws_mq_configuration" "external" {
  description    = "Custom configuration for ab-exc-aps1-staging-mq-external-integration on ActiveMQ 5.18.7"
  name           = "ab-exc-aps1-staging-mq-external-integration-configuration"
  engine_type    = "ActiveMQ"
  engine_version = "5.18"

  data = file("./configuration_files/external_mq.xml")
}

resource "aws_mq_configuration" "internal" {
  description    = "Custom configuration for ab-exc-aps1-staging-mq on ActiveMQ 5.18.7"
  name           = "ab-exc-aps1-staging-mq-configuration"
  engine_type    = "ActiveMQ"
  engine_version = "5.18"

  data = file("./configuration_files/internal_mq.xml")
}
