locals {
  lambda_prefix = {
    #Structured to add more kinds of lambda functions for different purposes
    cloudwatch_firehose = "cloudwatch-firehose"
  }

  lambda_func = {
    cloudwatch_firehose_sin = {
      lambda_func_name   = "${local.lambda_prefix["cloudwatch_firehose"]}-${local.env}-sin"
      lambda_description = "For converting Cloudwatch subcription from Json format to single line outputs"
      lambda_role        = data.terraform_remote_state.iam.outputs.lambda_s3_service_role_sin["arn"]
      lambda_tags = {
        purpose = "For converting Cloudwatch subcription from Json format to single line outputs"
      }
      # cloudwatch_log_group_name     = data.terraform_remote_state.cloudwatch.outputs.lambda_notify_slack_log_sin["name"]
      kms_key_arn                   = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin.arn
      lambda_dead_letter_target_arn = data.terraform_remote_state.sns.outputs.alerts_to_slack_id_sin
    }
  }
}
