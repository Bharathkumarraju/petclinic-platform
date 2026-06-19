module "ec2-ebs-sin" {
  source              = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/kms-provision-key"
  kms_key_alias       = lookup(local.kms_key["ec2_ebs_sin"], "kms_key_alias")
  kms_key_description = lookup(local.kms_key["ec2_ebs_sin"], "kms_key_description")
  kms_key_policy      = lookup(local.kms_key["ec2_ebs_sin"], "kms_key_policy")
  kms_key_tags        = lookup(local.kms_key["ec2_ebs_sin"], "kms_key_tags")
}

# Set default for entire region EBS to be automatically encrypted by this default key
resource "aws_ebs_encryption_by_default" "ebs_encryption_by_default" {
  enabled = true
}

resource "aws_ebs_default_kms_key" "ebs_encryption_default_key" {
  key_arn = module.ec2-ebs-sin.kms_key.arn
}
