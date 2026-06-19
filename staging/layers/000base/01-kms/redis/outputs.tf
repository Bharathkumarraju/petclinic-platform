output "kms_key_redis_sin" {
  description = "KMS for encrypting REDIS (Sin)"
  value       = module.redis-sin.kms_key
}

output "kms_key_redis_alias_sin" {
  description = "KMS Key Alias for REDIS Key (Sin)"
  value       = module.redis-sin.kms_key_alias
}
