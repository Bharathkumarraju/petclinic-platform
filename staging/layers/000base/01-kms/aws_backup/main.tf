module "aws-backup-sin" {
  source              = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/kms-provision-key"
  kms_key_alias       = lookup(local.kms_key["aws_backup_sin"], "kms_key_alias")
  kms_key_description = lookup(local.kms_key["aws_backup_sin"], "kms_key_description")
  kms_key_policy      = lookup(local.kms_key["aws_backup_sin"], "kms_key_policy")
  kms_key_tags        = lookup(local.kms_key["aws_backup_sin"], "kms_key_tags")
}
