output "kms_key_ec2_ebs_sin" {
  description = "KMS for encrypting EC2 EBS (Sin)"
  value       = module.ec2-ebs-sin.kms_key
}

output "kms_key_ec2_ebs_alias_sin" {
  description = "KMS Key Alias for EC2 EBS Key (Sin)"
  value       = module.ec2-ebs-sin.kms_key_alias
}
