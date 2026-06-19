output "kms_key_rds_postgres_sin" {
  description = "KMS for encrypting RDS postgres database"
  value = {
    for k, v in module.rds_database_sin : k => v.kms_key
  }
}

output "kms_key_rds_postgres_alias_sin" {
  description = "KMS Key Alias for RDS postgres database Key"
  value = {
    for k, v in module.rds_database_sin : k => v.kms_key_alias
  }
}
