data "aws_s3_bucket" "lambda_bucket_sin" {
  bucket = "abex-lambda-bucket-network-sin"
  # bucket = "abex-lambda-bucket-network-dev-sin"
}

module "cloudwatch_logs_s3_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs-s3"

  runtime = "python3.13"

  lambda_function_s3_bucket     = data.aws_s3_bucket.lambda_bucket_sin.id
  lambda_function_store_on_s3   = true
  lambda_function_name          = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "lambda_func_name")
  lambda_description            = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "lambda_description")
  lambda_role                   = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "lambda_role")
  cloudwatch_logs_export_bucket = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "cloudwatch_logs_export_bucket")
  kms_key_arn                   = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "kms_key_arn")
  lambda_dead_letter_target_arn = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "lambda_dead_letter_target_arn")

  lambda_function_version = "cloudwatch-logs-s3-4f47d80"

  cloudwatch_log_group_name = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "cloudwatch_log_group_name")
  env                       = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "env")
  tags                      = lookup(local.lambda_func["cloudwatch_logs_s3_sin"], "lambda_tags")

  shared_lambda_layer_arns = []
}