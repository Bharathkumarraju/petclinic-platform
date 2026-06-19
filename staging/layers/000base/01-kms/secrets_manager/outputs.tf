output "kms_key_secrets_mgr_sin" {
  description = "KMS for encrypting secrets manager"
  value       = module.secrets_manager_sin.kms_key
}

output "kms_key_secrets_mgr_alias_sin" {
  description = "KMS Key Alias for secrets manager Key"
  value       = module.secrets_manager_sin.kms_key_alias
}
