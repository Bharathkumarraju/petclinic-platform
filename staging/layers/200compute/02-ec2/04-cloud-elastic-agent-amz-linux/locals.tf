locals {
  vpc_id                              = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  private_subnet_id                   = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin[0]
  iam_role_name                       = data.terraform_remote_state.iam.outputs.ec2_elastic_agent_inst_profile_sin
  instance_name                       = "cloud-elastic-agent-${local.env}-01"
  instance_type                       = "t3.medium"
  volume_size                         = 50
  kms_key_arn                         = data.terraform_remote_state.kms_ec2_ebs.outputs.kms_key_ec2_ebs_sin.arn
  vpc_cidr                            = data.terraform_remote_state.network.outputs.main_vpc_cidr_block_sin
  additional_ingress_with_cidr_blocks = []

  agent = {
    elastic_version              = "9.3.2"
    fleet_server_url             = "https://abex-nonprod.fleet.vpce.ap-southeast-1.aws.elastic-cloud.com:443"
    secretsmanager_secret_key    = "elastic/abex-nonprod/aws"
    secretsmanager_secret_region = "ap-southeast-1"
  }
}
