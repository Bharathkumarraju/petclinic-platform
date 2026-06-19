locals {
  kms_policy_prefix = "kms"
  kms_key_alias = {
    sns = "sns"
  }

  kms_key = {
    sns_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["sns"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt SNS channels"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.sns_key_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt SNS channels"
      }
    }
  }
}
