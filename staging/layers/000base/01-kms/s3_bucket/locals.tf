locals {
  kms_policy_prefix = "kms"

  kms_key_alias = {
    s3_bucket = "s3-bucket"
  }

  kms_key = {
    s3_bucket_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["s3_bucket"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt S3 bucket"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.s3_bucket_key_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt S3 bucket"
      }
    }
  }
}
