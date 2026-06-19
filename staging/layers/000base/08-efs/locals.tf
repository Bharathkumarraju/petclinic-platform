locals {
  main_vpc_private_subnet_sin = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  efs_cronicle_id_sin         = data.terraform_remote_state.network-layer-1.outputs.efs_cronicle_id_sin
  comp_name                   = "abex-efs"

  default_policy_statements = [
    {
      sid    = "Allow EFS Mount and Write"
      effect = "Allow"
      actions = [
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientMount",
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      condition = [
        {
          test     = "Bool"
          variable = "elasticfilesystem:AccessedViaMountTarget"
          values   = ["true"]
        }
      ]
    },
  ]

  default_lifecycle_policy = {
    transition_to_ia                    = "AFTER_180_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  efs_storage = {
    cronicle_efs_sin = {
      efs_name          = "${local.comp_name}-cronicle-${local.env}-sin"
      efs_description   = "For cronicle NFS mounting"
      policy_statements = local.default_policy_statements
      lifecycle_policy  = local.default_lifecycle_policy
      efs_tags = {
        purpose = "For cronicle NFS mounting"
      }
    }
  }
}
