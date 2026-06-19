locals {
  kms_policy_prefix = "kms"
  kms_key_alias = {
    ts_database = "ts-db-kms"
  }

  kms_key = {
    marketdata_db_sin = {
      kms_key_alias       = format("%s-marketdata-ts-%s-%s-sin", local.kms_policy_prefix, local.kms_key_alias["ts_database"], local.env)
      kms_key_description = "KMS key to encrypt Marketdata Timeseries Database"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.db_kms_policy.json
      kms_key_tags = {
        purpose = "KMS key to encrypt Marketdata timeseries database"
      }
    }
  }
}
