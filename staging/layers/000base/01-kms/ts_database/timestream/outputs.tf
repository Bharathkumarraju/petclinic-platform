output "kms_key_ts_db_sin" {
  description = "KMS keys for encrypting timeseries databases"
  value = {
    for k, v in module.ts_database_sin : k => v.kms_key
  }
}

output "kms_key_ts_db_alias_sin" {
  description = "KMS Key Alias for timeseries databases"
  value = {
    for k, v in module.ts_database_sin : k => v.kms_key_alias
  }
}
