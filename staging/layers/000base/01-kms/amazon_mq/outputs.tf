output "kms_key_mq_sin" {
  description = "KMS for encrypting MQ broker"
  value       = module.mq-broker-sin.kms_key
}

output "kms_key_mq_alias_sin" {
  description = "KMS Key Alias for MQ broker Key"
  value       = module.mq-broker-sin.kms_key_alias
}
