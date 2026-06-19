locals {
  kms_policy_prefix = "kms"
  kms_key_alias = {
    rds_database = "rds-db-kms"
  }

  kms_key = {
    rds_eprime_db_sin = {
      kms_key_alias       = format("%s-eprime-%s-%s-sin", local.kms_policy_prefix, local.kms_key_alias["rds_database"], local.env)
      kms_key_description = "KMS key to encrypt RDS eprime Database"
      #Pull this value from key-policies sub-directory
      kms_key_policy = data.aws_iam_policy_document.db_kms_policy.json
      kms_key_tags = {
        purpose = "KMS key to encrypt RDS eprime database"
      }
    }
  }
}
