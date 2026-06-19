output "kms_key_cloudwatch_logs_sin" {
  description = "KMS for encrypting Cloudwatch logs (Sin)"
  value       = module.cloudwatch-logs-sin.kms_key
}

output "kms_key_cloudwatch_logs_alias_sin" {
  description = "KMS Key Alias for Cloudwatch logs Key (Sin)"
  value       = module.cloudwatch-logs-sin.kms_key_alias
}
