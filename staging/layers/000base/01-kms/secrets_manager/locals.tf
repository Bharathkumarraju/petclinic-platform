locals {

  kms_policy_prefix = "kms"

  kms_key_alias = {
    #Structured to add more kinds of logs for different services
    secrets_manager = "secrets-manager"
    #mq_log            = "/aws/mq-log"
  }

  kms_key = {
    secrets_manager_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["secrets_manager"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt secrets"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.secrets_manager_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt secrets"
      }
    }
  }
}
