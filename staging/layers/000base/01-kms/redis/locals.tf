locals {
  kms_policy_prefix = "kms"
  kms_key_alias = {
    #Structured to add more kinds of logs for different services
    redis = "redis"
  }

  kms_key = {
    redis_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["redis"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt REDIS clusters"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.redis_key_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt REDIS clusters"
      }
    }
  }
}
