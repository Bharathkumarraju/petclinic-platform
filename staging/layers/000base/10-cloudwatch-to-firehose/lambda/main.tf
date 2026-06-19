data "aws_s3_bucket" "lambda_bucket_sin" {
  bucket = "abex-lambda-bucket-network-sin"
}

module "cloudwatch_firehose_transformer" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch_firehose_transformer"

  runtime = "python3.13"

  lambda_function_s3_bucket   = data.aws_s3_bucket.lambda_bucket_sin.id
  lambda_function_store_on_s3 = true
  lambda_function_name        = local.lambda_func["cloudwatch_firehose_sin"]["lambda_func_name"]
  lambda_description          = local.lambda_func["cloudwatch_firehose_sin"]["lambda_description"]
  lambda_role                 = local.lambda_func["cloudwatch_firehose_sin"]["lambda_role"]

  lambda_function_version = "cloudwatch-firehose-576ca93"

  kms_key_arn                   = local.lambda_func["cloudwatch_firehose_sin"]["kms_key_arn"]
  lambda_dead_letter_target_arn = local.lambda_func["cloudwatch_firehose_sin"]["lambda_dead_letter_target_arn"]

  log_events = true
  tags       = local.lambda_func["cloudwatch_firehose_sin"]["lambda_tags"]

#  shared_opentelemetry_layer_arn = data.terraform_remote_state.lambda_layers.outputs.opentelemetry_layer_arn
  shared_lambda_layer_arns = []
}
