output "vpc_flow_log_service_role_sin" {
  description = "Service Role created"
  value       = module.vpc_flow_log_role_sin.service_role
}

output "lambda_s3_service_role_sin" {
  description = "Service Role created "
  value       = module.lambda_s3_log_role_sin.service_role
}

output "ec2_default_service_role_sin" {
  description = "Service Role created"
  value       = module.ec2_default_role_sin.service_role
}

output "ec2_default_service_inst_profile_sin" {
  description = "Service Instance Profile created"
  value       = module.ec2_default_role_sin.instance_profile
}

output "rds_enhanced_monitoring_default_service_role_sin" {
  description = "Service Role created"
  value       = module.rds_enhanced_monitoring_log_role_sin.service_role
}

output "rds_enhanced_monitoring_default_service_role_arn_sin" {
  description = "Service Role ARN created"
  value       = module.rds_enhanced_monitoring_log_role_sin.service_role_arn
}

output "ec2_cronicle_service_role_sin" {
  description = "Service Role created"
  value       = module.ec2_cronicle_role_sin.service_role
}

output "ec2_cronicle_inst_profile_sin" {
  description = "Service Instance Profile created"
  value       = module.ec2_cronicle_role_sin.instance_profile
}

output "ec2_elastic_agent_role_sin" {
  description = "Elastic Agent Service Role created"
  value       = module.ec2_elastic_agent_role_sin.service_role
}

output "ec2_elastic_agent_inst_profile_sin" {
  description = "Elastic Agent Service Instance Profile created"
  value       = module.ec2_elastic_agent_role_sin.instance_profile
}

output "cloudwatch_s3_log_role_sin" {
  description = "Service Role created for Cloudwatch Logs backup to S3 "
  value       = module.cloudwatch_s3_log_role_sin.service_role
}

output "aws_backup_role_sin" {
  description = "Service Role created for AWS Backup"
  value       = module.aws_backup_role_sin.service_role
}
output "github_actions_role_sin" {
  description = "Role for Github Actions"
  value       = module.github_actions_role_sin.service_role
}
output "ses_logs_ses_firehose" {
  description = "Role for SES to write to Kinesis Firehose"
  value       = module.ses_logs_ses_firehose.service_role
}
output "ses_logs_firehose_s3" {
  description = "Role for Kinesis Firehose to write to S3"
  value       = module.ses_logs_firehose_s3.service_role
}

output "dms-vpc-role_sin" {
  description = "Service Role created for DMS-RDS"
  value       = module.dms-vpc-role_sin.service_role
}
output "cloudwatch_logs_firehose" {
  description = "Role for SES to write to Kinesis Firehose"
  value       = module.cloudwatch_logs_firehose.service_role
}
output "cloudwatch_logs_firehose_s3" {
  description = "Role for Kinesis Firehose to write to S3"
  value       = module.cloudwatch_logs_firehose_s3.service_role
}


# output "network_eks_access_service_role_sin" {
#   description = "Cross cluster role"
#   value       = module.network_eks_access_role_sin.service_role
# }

# output "network_eks_access_service_role_arn_sin" {
#   description = "Cross cluster role ARN created"
#   value       = module.network_eks_access_role_sin.service_role_arn
# }

output "network_dev_eks_access_service_role_sin" {
  description = "Cross cluster role"
  value       = module.network_dev_eks_access_role_sin.service_role
}

output "network_dev_eks_access_service_role_arn_sin" {
  description = "Cross cluster role ARN created"
  value       = module.network_dev_eks_access_role_sin.service_role_arn
}
