output "kms_key_sqs_sin" {
  description = "KMS for encrypting SQS"
  value       = module.sqs-sin.kms_key
}

output "kms_key_sqs_sin_alias_sin" {
  description = "KMS Key Alias for encrypting SQS"
  value       = module.sqs-sin.kms_key_alias
}

# output "kms_key_cloudwatch_logs_vir" {
#   description = "KMS for encrypting Cloudwatch logs (Vir)"
#   value       = module.cloudwatch-logs-vir.kms_key
# }

# output "kms_key_cloudwatch_logs_alias_vir" {
#   description = "KMS Key Alias for Cloudwatch logs Key (Vir)"
#   value       = module.cloudwatch-logs-vir.kms_key_alias
# }
