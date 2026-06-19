# output "main_vpc_flow_log_group_sin" {
#   description = "Main VPC Flow Log Group"
#   value       = module.main_vpc_flow_log_sin.cloudwatch_log_group
# }

output "lambda_notify_slack_log_sin" {
  description = "Lambda Notify Slack Log Group"
  value       = module.lambda_notify_slack_log_sin.cloudwatch_log_group
}
output "cloudwatch_s3_log_sin" {
  description = "Lambda Notify Slack Log Group"
  value       = module.cloudwatch_s3_log_sin.cloudwatch_log_group
}
output "cloudwatch_firehose_log_sin" {
  description = "Lambda Cloudwatch Firehose Log Group"
  value       = module.cloudwatch_firehose_log_sin.cloudwatch_log_group
}


# output "cloudwatch_log_groups_rds_sin" {
#   description = "log groups for the rds"
#   value = {
#     for k, v in module.rds_database_cloudwatch_logs : k => v.cloudwatch_log_group
#   }
# }
# output "ec2_ubuntu_auth_log" {
#   description = "EC2 Ubuntu Auth Log"
#   value       = module.ec2_ubuntu_auth_log.cloudwatch_log_group
# }
# output "ec2_ubuntu_syslog_log" {
#   description = "EC2 Ubuntu Syslog Log"
#   value       = module.ec2_ubuntu_syslog_log.cloudwatch_log_group
# }
# output "ec2_amazonlinux_secure_log" {
#   description = "EC2 Amazonlinux Secure Log"
#   value       = module.ec2_amazonlinux_secure_log.cloudwatch_log_group
# }
# output "ec2_amazonlinux_messages_log" {
#   description = "EC2 Amazonlinux Messages Log"
#   value       = module.ec2_amazonlinux_messages_log.cloudwatch_log_group
# }
output "swift_sync_log" {
  description = "Swift Sync Application Log"
  value       = module.swift_sync_log.cloudwatch_log_group
}
# output "clara_finance_reports_log" {
#   description = "Clara Reports export to finance Log"
#   value       = module.clara_finance_reports_log.cloudwatch_log_group
# }
# output "clara_span_reports_log" {
#   description = "Clara SPAN Report export to Market Participants and Risk Team"
#   value       = module.clara_span_reports_log.cloudwatch_log_group
# }
# output "exberry_md_collection_log" {
#   description = "Exberry Reports Collection Log"
#   value       = module.exberry_md_collection_log.cloudwatch_log_group
# }
# output "exberry_dsp_update_log" {
#   description = "Exberry dsp Update Log"
#   value       = module.exberry_dsp_update_log.cloudwatch_log_group
# }
# output "exberry_bootstrapping_log" {
#   description = "Exberry bootstrapping Log"
#   value       = module.exberry_bootstrapping_log.cloudwatch_log_group
# }
# output "risk_dsp_log" {
#   description = "Risk DSP Log"
#   value       = module.risk_dsp_log.cloudwatch_log_group
# }
# output "risk_dashboard_log" {
#   description = "Risk Dashboard Log"
#   value       = module.risk_dashboard_log.cloudwatch_log_group
# }

# output "mdapi_log" {
#   description = "MDPAI Log"
#   value       = module.mdapi_log.cloudwatch_log_group
# }
# output "mmtapi_log" {
#   description = "MMTAPI Log"
#   value       = module.mmtapi_log.cloudwatch_log_group
# }
