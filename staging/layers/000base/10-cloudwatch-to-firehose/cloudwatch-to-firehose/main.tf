module "cloudwatch_logs_firehose" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch_sub_to_firehose"

  for_each = local.firehose

  firehose_name           = each.value.firehose_name
  firehose_role           = each.value.firehose_role
  cloudwatch_prefix       = each.value.cloudwatch_prefix
  cloudwatch_bucket       = each.value.cloudwatch_bucket
  cloudwatch_bucket_kms   = each.value.cloudwatch_bucket_kms
  cloudwatch_role         = each.value.cloudwatch_role
  log_group_name          = each.value.log_group_name
  log_filter_pattern      = each.value.log_filter_pattern
  enable_lambda_processor = each.value.enable_lambda_processor
  lambda_processor_arn    = each.value.lambda_processor_arn
  firehose_tags           = each.value.firehose_tags
}
