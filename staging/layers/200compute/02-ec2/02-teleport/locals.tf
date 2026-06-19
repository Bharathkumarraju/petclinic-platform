locals {
  cluster_prefix   = "abex-teleport"
  ami_id           = data.aws_ami.ubuntu_golden_image.id // ubuntu-golden-image
  db_instance_type = "t3a.medium"
  cluster_name     = "abex-teleport-network"
  ec2_tags_sin = {
    env              = local.env
    map-migrated     = "mig46499"
    Name             = "${local.cluster_prefix}-db-service"
    purpose          = "Provides Teleport DB Service"
    TeleportCluster  = local.cluster_name
    TeleportRole     = "db-service"
    UpgradeToNewAMI  = "true"
    CreatedByTF      = "true"
    ManagedByAnsible = "false"
    test             = "value"
  }
  kms_ec2_ebs = data.terraform_remote_state.kms_ec2_ebs.outputs.kms_key_ec2_ebs_sin.arn
  key_name    = "ansible-abaxx-key"
  # ec2_teleport_db_inst_profile_sin = data.terraform_remote_state.iam.outputs.ec2_teleport_db_inst_profile_sin
  ec2_teleport_db_id_sin       = data.terraform_remote_state.network-layer-1.outputs.ec2_teleport_db_id_sin
  main_vpc_private_subnets_sin = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin

  // Templates
  teleport_cloud_db_template = file("${path.module}/tmpl/teleport-cloud-db-user-data.tpl")
}




