output "kms_key_s3_sin" {
  description = "KMS for encrypting S3 buckets"
  value       = module.s3-bucket-sin.kms_key
}

output "kms_key_s3_alias_sin" {
  description = "KMS Key Alias for S3 buckets Key"
  value       = module.s3-bucket-sin.kms_key_alias
}

output "kms_key_arn_s3_sin" {
  description = "KMS for encrypting S3 buckets"
  value       = module.s3-bucket-sin.kms_key_arn
}
