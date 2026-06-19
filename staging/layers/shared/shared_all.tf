module "common" {
  source = "git@github.com-abaxx:abaxxsingapore/abex-aws-common.git"
}

locals {
  region_map = module.common.region_map
  account_id = module.common.account_id_map[local.env] # 993533333148
  # infra_account_id              = module.common.account_id_map["infra"]
  network_account_id        = module.common.account_id_map["network"]
  common_kms_key_ec2_ebs_id = module.common.common_kms_key_ec2_ebs_sin_arn
  principal_org_id          = module.common.principal_org_id
  principal_org_root_id     = module.common.principal_org_root_id
  principal_org_paths       = module.common.principal_org_paths
  tf_provisioner_role       = module.common.tf_provisioner_role # abaxx-exch-terraform-provisioner
  role_arn                  = "arn:aws:iam::${local.account_id}:role/${local.tf_provisioner_role}"
}

data "aws_ami" "ubuntu_golden_image" {
  most_recent = true
  owners      = [local.network_account_id]
  filter {
    name   = "name"
    values = ["*packer-ubuntu-20.04-golden-image*"]
  }
}
