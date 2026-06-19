# module "main_vpc_flow_log_sin" {
#   source                         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"
#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["main_vpc_flow_log_sin"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["main_vpc_flow_log_sin"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["main_vpc_flow_log_sin"], "cloudwatch_logs_encrypt_key")
# }

module "lambda_notify_slack_log_sin" {
  source                         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"
  cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["lambda_notify_slack_log_sin"], "cloudwatch_log")
  cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["lambda_notify_slack_log_sin"], "log_tags")
  cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["lambda_notify_slack_log_sin"], "cloudwatch_logs_encrypt_key")
}

module "cloudwatch_s3_log_sin" {
  source                         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"
  cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["cloudwatch_s3_log_sin"], "cloudwatch_log")
  cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["cloudwatch_s3_log_sin"], "log_tags")
  cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["cloudwatch_s3_log_sin"], "cloudwatch_logs_encrypt_key")
}

module "cloudwatch_firehose_log_sin" {
  source                         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"
  cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["cloudwatch_firehose_log_sin"], "cloudwatch_log")
  cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["cloudwatch_firehose_log_sin"], "log_tags")
  cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["cloudwatch_firehose_log_sin"], "cloudwatch_logs_encrypt_key")
}

# module "rds_database_cloudwatch_logs" {
#   source                         = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"
#   for_each                       = local.cloudwatch_rds_log_groups
#   cloudwatch_log_name            = lookup(local.cloudwatch_rds_log_groups[each.key], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_rds_log_groups[each.key], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_rds_log_groups[each.key], "cloudwatch_logs_encrypt_key")
# }

# module "ec2_ubuntu_auth_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["ec2_ubuntu_auth_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["ec2_ubuntu_auth_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["ec2_ubuntu_auth_log"], "cloudwatch_logs_encrypt_key")
# }

# module "ec2_ubuntu_syslog_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["ec2_ubuntu_syslog_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["ec2_ubuntu_syslog_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["ec2_ubuntu_syslog_log"], "cloudwatch_logs_encrypt_key")
# }

# module "ec2_amazonlinux_secure_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["ec2_amazonlinux_secure_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["ec2_amazonlinux_secure_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["ec2_amazonlinux_secure_log"], "cloudwatch_logs_encrypt_key")
# }

# module "ec2_amazonlinux_messages_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["ec2_amazonlinux_messages_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["ec2_amazonlinux_messages_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["ec2_amazonlinux_messages_log"], "cloudwatch_logs_encrypt_key")
# }

module "swift_sync_log" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

  cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["swift_sync_log"], "cloudwatch_log")
  cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["swift_sync_log"], "log_tags")
  cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["swift_sync_log"], "cloudwatch_logs_encrypt_key")
}

# module "clara_finance_reports_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["clara_finance_reports_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["clara_finance_reports_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["clara_finance_reports_log"], "cloudwatch_logs_encrypt_key")
# }

# module "clara_span_reports_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["clara_span_reports_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["clara_span_reports_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["clara_span_reports_log"], "cloudwatch_logs_encrypt_key")
# }

# module "exberry_md_collection_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["exberry_md_collection_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["exberry_md_collection_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["exberry_md_collection_log"], "cloudwatch_logs_encrypt_key")
# }
# module "exberry_dsp_update_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["exberry_dsp_update_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["exberry_dsp_update_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["exberry_dsp_update_log"], "cloudwatch_logs_encrypt_key")
# }
# module "exberry_bootstrapping_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["exberry_bootstrapping_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["exberry_bootstrapping_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["exberry_bootstrapping_log"], "cloudwatch_logs_encrypt_key")
# }

# module "risk_dsp_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["risk_dsp_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["risk_dsp_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["risk_dsp_log"], "cloudwatch_logs_encrypt_key")
# }
# module "risk_dashboard_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["risk_dashboard_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["risk_dashboard_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["risk_dashboard_log"], "cloudwatch_logs_encrypt_key")
# }

# module "mdapi_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["mdapi_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["mdapi_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["mdapi_log"], "cloudwatch_logs_encrypt_key")
# }

# module "mmtapi_log" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"

#   cloudwatch_log_name            = lookup(local.cloudwatch_log_groups["mmtapi_log"], "cloudwatch_log")
#   cloudwatch_log_group_tags      = lookup(local.cloudwatch_log_groups["mmtapi_log"], "log_tags")
#   cloudwatch_logs_encryption_key = lookup(local.cloudwatch_log_groups["mmtapi_log"], "cloudwatch_logs_encrypt_key")
# }
