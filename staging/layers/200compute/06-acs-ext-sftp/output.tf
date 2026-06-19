# Transfer Server
output "acs_ext_sftp_server_id" {
  description = "The unique identifier of the acs_ext_sftp Transfer Family server"
  value       = module.acs_ext_sftp.transfer_server_id
}

output "acs_ext_sftp_server_arn" {
  description = "The ARN of the acs_ext_sftp Transfer Family server"
  value       = module.acs_ext_sftp.transfer_server_arn
}

output "acs_ext_sftp_server_endpoint" {
  description = "The endpoint of the acs_ext_sftp Transfer Family server"
  value       = module.acs_ext_sftp.transfer_server_endpoint
}

output "acs_ext_sftp_server_domain" {
  description = "The storage domain of the acs_ext_sftp Transfer Family server"
  value       = module.acs_ext_sftp.transfer_server_domain
}

data "aws_vpc_endpoint" "acs_ext_sftp" {
  id = module.acs_ext_sftp.transfer_server_vpc_endpoint_id
}

data "aws_network_interface" "acs_ext_sftp" {
  for_each = toset(data.aws_vpc_endpoint.acs_ext_sftp.network_interface_ids)
  id       = each.value
}

output "acs_ext_sftp_private_ips" {
  description = "Private IP addresses of the SFTP server's VPC endpoint ENIs"
  value       = [for eni in data.aws_network_interface.acs_ext_sftp : eni.private_ip]
}

# CloudWatch Log Group
output "acs_ext_sftp_log_group_name" {
  description = "The CloudWatch log group name for acs_ext_sftp"
  value       = module.acs_ext_sftp.cloudwatch_log_group_name
}

output "acs_ext_sftp_log_group_arn" {
  description = "The CloudWatch log group ARN for acs_ext_sftp"
  value       = module.acs_ext_sftp.cloudwatch_log_group_arn
}

output "acs_ext_sftp_log_group_tags_all" {
  description = "All tags on the acs_ext_sftp CloudWatch log group"
  value       = module.acs_ext_sftp.cloudwatch_log_group_tags_all
}

# IAM Logging Role
output "acs_ext_sftp_iam_role_id" {
  description = "The ID of the acs_ext_sftp IAM logging role"
  value       = module.acs_ext_sftp.iam_role_id
}

output "acs_ext_sftp_iam_role_arn" {
  description = "The ARN of the acs_ext_sftp IAM logging role"
  value       = module.acs_ext_sftp.iam_role_arn
}

output "acs_ext_sftp_iam_role_name" {
  description = "The name of the acs_ext_sftp IAM logging role"
  value       = module.acs_ext_sftp.iam_role_name
}

output "acs_ext_sftp_iam_role_unique_id" {
  description = "The stable unique identifier for the acs_ext_sftp IAM role"
  value       = module.acs_ext_sftp.iam_role_unique_id
}

output "acs_ext_sftp_iam_role_create_date" {
  description = "The creation date of the acs_ext_sftp IAM role"
  value       = module.acs_ext_sftp.iam_role_create_date
}

output "acs_ext_sftp_iam_role_tags_all" {
  description = "All tags on the acs_ext_sftp IAM role"
  value       = module.acs_ext_sftp.iam_role_tags_all
}

output "acs_ext_sftp_iam_role_policy_attachment_id" {
  description = "The ID of the acs_ext_sftp IAM role policy attachment"
  value       = module.acs_ext_sftp.iam_role_policy_attachment_id
}

# Security Group
output "acs_ext_sftp_security_group_id" {
  description = "The ID of the acs_ext_sftp security group"
  value       = module.acs_ext_sftp.security_group_id
}

output "acs_ext_sftp_security_group_arn" {
  description = "The ARN of the acs_ext_sftp security group"
  value       = module.acs_ext_sftp.security_group_arn
}

output "acs_ext_sftp_security_group_name" {
  description = "The name of the acs_ext_sftp security group"
  value       = module.acs_ext_sftp.security_group_name
}