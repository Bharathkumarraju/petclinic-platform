module "elastic_agent_ec2" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//ec2//elastic-agent"

  env                                 = local.env
  vpc_id                              = local.vpc_id
  private_subnet_id                   = local.private_subnet_id
  iam_role_name                       = local.iam_role_name
  instance_name                       = local.instance_name
  instance_type                       = local.instance_type
  volume_size                         = local.volume_size
  kms_key_arn                         = local.kms_key_arn
  vpc_cidr                            = local.vpc_cidr
  additional_ingress_with_cidr_blocks = local.additional_ingress_with_cidr_blocks
}

module "elastic_observability_agent_ec2" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules//ec2//elastic-agent"

  env               = local.env
  vpc_id            = local.vpc_id
  private_subnet_id = local.private_subnet_id
  iam_role_name     = local.iam_role_name
  # instance_name     = local.instance_name
  instance_name = "cloud-elastic-observability-agent-${local.env}-01"
  # instance_type                       = local.instance_type
  instance_type                       = "t4g.medium"
  instance_architecture               = "arm64"
  volume_size                         = local.volume_size
  kms_key_arn                         = local.kms_key_arn
  vpc_cidr                            = local.vpc_cidr
  additional_ingress_with_cidr_blocks = local.additional_ingress_with_cidr_blocks

  agent = local.agent
}
