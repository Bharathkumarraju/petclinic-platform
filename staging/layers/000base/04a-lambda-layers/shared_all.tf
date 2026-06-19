module "common" {
  source = "git@github.com:abaxxsingapore/abex-aws-common.git"
}

locals {
  account_id          = module.common.account_id_map[local.env]
  tf_provisioner_role = module.common.tf_provisioner_role
  role_arn            = "arn:aws:iam::${local.account_id}:role/${local.tf_provisioner_role}"
}
