output "kms_key_sns_sin" {
  description = "KMS for encrypting SNS channels"
  value       = module.sns_sin.kms_key
}


output "kms_key_sns_alias_sin" {
  description = "KMS Key Alias for SNS channels"
  value       = module.sns_sin.kms_key_alias
}
