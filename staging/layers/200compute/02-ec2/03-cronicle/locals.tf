locals {
  app_prefix = "abex-cronicle"
  # ami_id           = "ami-0ae49a560c8f98c00" // ubuntu-golden-image
  #ami_id  = data.aws_ami.ubuntu_golden_image.id
  #ami_id        = "ami-0108184184751d80d" // from backup
  instance_type = "t3a.medium"

  key_name                      = "ansible-abaxx-key"
  ec2_cronicle_inst_profile_sin = data.terraform_remote_state.iam.outputs.ec2_cronicle_inst_profile_sin
  ec2_cronicle_id_sin           = data.terraform_remote_state.network-layer-1.outputs.ec2_cronicle_id_sin
  main_vpc_private_subnets_sin  = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin

  internal_certificate_arn = "arn:aws:acm:ap-southeast-1:993533333148:certificate/cf03fb37-f2d1-4342-a100-ca2667eb3641"

  network_vpc_cidr   = "172.23.0.0/21"
  server1_private_ip = "10.40.8.80"
  server2_private_ip = "10.40.10.80"
  tags = {
    "map-migrated" = "mig46499"
    "env"          = local.env
  }

}
