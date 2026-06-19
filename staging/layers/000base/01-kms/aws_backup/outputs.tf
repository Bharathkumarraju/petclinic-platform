output "kms_key_aws_backup_sin" {
  description = "KMS for encrypting AWS Backup resources (Sin)"
  value       = module.aws-backup-sin.kms_key
}

output "kms_key_aws_backup_alias_sin" {
  description = "KMS Key Alias for AWS Backup Key (Sin)"
  value       = module.aws-backup-sin.kms_key_alias
}
