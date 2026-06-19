module "rds_database_sin" {
  source              = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/kms-provision-key"
  for_each            = local.kms_key
  kms_key_alias       = lookup(local.kms_key[each.key], "kms_key_alias")
  kms_key_description = lookup(local.kms_key[each.key], "kms_key_description")
  kms_key_policy      = lookup(local.kms_key[each.key], "kms_key_policy")
  kms_key_tags        = lookup(local.kms_key[each.key], "kms_key_tags")
}

moved {
  from = module.rds_database_sin["rds_clarity_db_sin"]
  to   = module.rds_database_sin["rds_db_sin"]
}