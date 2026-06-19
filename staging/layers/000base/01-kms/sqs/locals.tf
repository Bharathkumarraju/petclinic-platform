locals {
  kms_policy_prefix = "kms"
  kms_key_alias = {
    sqs = "sqs"
  }

  kms_key = {
    sqs_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["sqs"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt SQS queue"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.sqs_sin.json
      kms_key_tags = {
        env          = local.env
        map-migrated = "mig46499"
        purpose      = "KMS key to encrypt SQS queue"
      }
    }
  }
}
