# ============================================================
# RDS (ACS MySQL)
# ============================================================

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = module.db.db_instance_identifier
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.db.db_instance_arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = module.db.db_instance_endpoint
}

output "db_instance_address" {
  description = "The hostname of the RDS instance (without port)"
  value       = module.db.db_instance_address
}

output "db_instance_port" {
  description = "The port the RDS instance is listening on"
  value       = module.db.db_instance_port
}

output "db_instance_name" {
  description = "The database name"
  value       = module.db.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the RDS instance"
  value       = module.db.db_instance_username
  sensitive   = true
}

output "db_instance_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master user credentials"
  value       = module.db.db_instance_master_user_secret_arn
}

output "db_instance_status" {
  description = "The current status of the RDS instance"
  value       = module.db.db_instance_status
}

output "db_subnet_group_name" {
  description = "The DB subnet group name used by the RDS instance"
  value       = module.db.db_subnet_group_id
}

output "db_parameter_group_id" {
  description = "The DB parameter group ID"
  value       = module.db.db_parameter_group_id
}

output "db_option_group_id" {
  description = "The DB option group ID"
  value       = module.db.db_option_group_id
}

# ============================================================
# Security Group (ACS SG)
# ============================================================

output "acs_security_group_id" {
  description = "The ID of the ACS MySQL security group"
  value       = module.acs_sg.security_group_id
}

output "acs_security_group_arn" {
  description = "The ARN of the ACS MySQL security group"
  value       = module.acs_sg.security_group_arn
}

output "acs_security_group_name" {
  description = "The name of the ACS MySQL security group"
  value       = module.acs_sg.security_group_name
}

# ============================================================
# KMS Key
# ============================================================

output "kms_key_id" {
  description = "The ID of the KMS key used for RDS encryption"
  value       = aws_kms_key.acs-kms.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption"
  value       = aws_kms_key.acs-kms.arn
}

output "kms_key_alias" {
  description = "The alias of the KMS key"
  value       = aws_kms_alias.acs-kms-alias.name
}

# ============================================================
# Caller Identity
# ============================================================

output "aws_account_id" {
  description = "The AWS account ID in which resources are deployed"
  value       = data.aws_caller_identity.current.account_id
}
