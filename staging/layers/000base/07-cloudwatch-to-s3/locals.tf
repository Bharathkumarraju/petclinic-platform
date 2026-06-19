locals {
  cloudwatch_logs_export_bucket = "abex-cloudwatch-archive-bucket-log-archive-sin"
  lambda_prefix = {
    #Structured to add more kinds of lambda functions for different purposes
    cloudwatch_logs_s3 = "cloudwatch-logs-to-s3"
  }

  lambda_func = {
    cloudwatch_logs_s3_sin = {
      lambda_func_name   = "${local.lambda_prefix["cloudwatch_logs_s3"]}-${local.env}-sin"
      lambda_description = "For cloudwatch backup to S3"
      lambda_role        = data.terraform_remote_state.iam.outputs.cloudwatch_s3_log_role_sin["arn"]
      lambda_tags = {
        purpose = "For cloudwatch backup to S3"
      }
      cloudwatch_logs_export_bucket = local.cloudwatch_logs_export_bucket
      cloudwatch_log_group_name     = data.terraform_remote_state.cloudwatch.outputs.cloudwatch_s3_log_sin["name"]
      env                           = local.env
      kms_key_arn                   = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin.arn
      lambda_dead_letter_target_arn = data.terraform_remote_state.sns.outputs.alerts_to_slack_id_sin
    }
  }
}

