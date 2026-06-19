data "aws_s3_bucket" "lambda_bucket_sin" {
  bucket = "abex-lambda-bucket-network-sin"
}

module "alerts_slack_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/sns-notify-slack"

  runtime = "python3.13"

  create           = true
  create_sns_topic = false

  lambda_function_s3_bucket   = data.aws_s3_bucket.lambda_bucket_sin.id
  lambda_function_store_on_s3 = true
  lambda_function_name        = lookup(local.lambda_func["alerts_slack_sin"], "lambda_func_name")
  lambda_description          = lookup(local.lambda_func["alerts_slack_sin"], "lambda_description")
  lambda_role                 = lookup(local.lambda_func["alerts_slack_sin"], "lambda_role")
  cloudwatch_log_group_name   = lookup(local.lambda_func["alerts_slack_sin"], "cloudwatch_log_group_name")

  lambda_function_version = "sns-notify-slack-576ca93"

  slack_channel                 = lookup(local.lambda_func["alerts_slack_sin"], "slack_channel")
  slack_username                = lookup(local.lambda_func["alerts_slack_sin"], "slack_username")
  slack_webhook_url             = lookup(local.lambda_func["alerts_slack_sin"], "slack_hook_url_ciphertext")
  kms_key_arn                   = lookup(local.lambda_func["alerts_slack_sin"], "ciphertext_key")
  sns_topic_name                = lookup(local.lambda_func["alerts_slack_sin"], "sns_topic_name")
  lambda_dead_letter_target_arn = lookup(local.lambda_func["alerts_slack_sin"], "lambda_dead_letter_target_arn")

  enable_sns_topic_delivery_status_logs = true

  log_events = true
  tags       = lookup(local.lambda_func["alerts_slack_sin"], "lambda_tags")
  shared_lambda_layer_arns = []

#  shared_opentelemetry_layer_arn = data.terraform_remote_state.lambda_layers.outputs.opentelemetry_layer_arn
}
