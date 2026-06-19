locals {
  kms_policy_prefix = "kms"

  kms_key_alias = {
    #Structured to add more kinds of logs for different services
    cloudwatch_logs = "cloudwatch-logs"
    #db_log            = "/aws/db-log"
  }

  kms_key = {
    cloudwatch_logs_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["cloudwatch_logs"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt cloudwatch logs"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.cloudwatch_logs_key_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt cloudwatch logs"
      }
    }
  }
}
