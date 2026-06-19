locals {
  # Slack hook url parameters
  slack_channel                 = "aws-notifications"
  slack_username                = "AWS Alerts"
  slack_hook_url_ciphertext_sin = "AQICAHie521zWMfBb7P7MgsCKv8N3eCq4ULKSU2EnQwzIwbKUgGS8E1ETwTy+PnJDQJ2hGeVAAAAsjCBrwYJKoZIhvcNAQcGoIGhMIGeAgEAMIGYBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDD8tZKqMFSDh0mE0tQIBEIBrdwxXAjHehr7zIA8qcQkDcOKX4fJSQjCOBlIG50uuu18z1adYbXn48IwMCiOj+hJV2WKr8ISDrlY5euEaJLR7SthyNy5gG+Y4T6i1KRLLTkXD8NzPI340GaoUwzoIjEV3V/cXm9uRtqmnDAk="
  # slack_hook_url_ciphertext_vir  = "AQICAHiDJPn2k0amN5A+uWMDfMLPQVgpOFhyk31WkWldVv5VrQEXrLW3XGByjk8qTyajPAFdAAAAsjCBrwYJKoZIhvcNAQcGoIGhMIGeAgEAMIGYBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDO0zc/o4F726lPl2sAIBEIBrsGWD9RkcbmU/b4VHvRFpBcOs+XCr3P+8/Et66Rj6nbxzZ5RtEnG68YQCZ13ztHTRvdeHLkaHOLtHr45hXw7qCKKMG+nTkYYPjVWH3whTkJO71YeldJ/vk8JBei1RTZZLvi7pTgDVrymxFHw="

  lambda_prefix = {
    #Structured to add more kinds of lambda functions for different purposes
    alerts_slack = "alerts-slack"
  }

  lambda_func = {
    alerts_slack_sin = {
      lambda_func_name   = "${local.lambda_prefix["alerts_slack"]}-${local.env}-sin"
      lambda_description = "For sending Alerts to Slack"
      lambda_role        = data.terraform_remote_state.iam.outputs.lambda_s3_service_role_sin["arn"]
      lambda_tags = {
        purpose = "For sending Alerts to Slack"
      }
      slack_channel                 = local.slack_channel
      slack_username                = local.slack_username
      slack_hook_url_ciphertext     = local.slack_hook_url_ciphertext_sin
      sns_topic_name                = data.terraform_remote_state.sns.outputs.alerts_to_slack_topic_name_sin
      ciphertext_key                = data.terraform_remote_state.kms.outputs.kms_key_sns_sin["arn"]
      cloudwatch_log_group_name     = data.terraform_remote_state.cloudwatch.outputs.lambda_notify_slack_log_sin["name"]
      lambda_dead_letter_target_arn = data.terraform_remote_state.sns.outputs.alerts_to_slack_id_sin
    }
  }
}
