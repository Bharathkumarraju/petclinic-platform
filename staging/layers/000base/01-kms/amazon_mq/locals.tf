locals {
  kms_policy_prefix = "kms"

  kms_key_alias = {
    #Structured to add more kinds of logs for different services
    mq_broker = "mq-broker-kms"
    #mq_log            = "/aws/mq-log"
  }

  kms_key = {
    mq_broker_sin = {
      kms_key_alias       = "${local.kms_policy_prefix}-${local.kms_key_alias["mq_broker"]}-${local.env}-sin"
      kms_key_description = "KMS key to encrypt MQ broker"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.mq_broker_key_sin.json
      kms_key_tags = {
        purpose = "KMS key to encrypt MQ broker"
      }
    }
  }
}
