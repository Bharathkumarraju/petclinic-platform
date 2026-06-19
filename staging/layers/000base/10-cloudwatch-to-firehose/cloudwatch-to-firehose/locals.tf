locals {
  firehose_s3_role         = data.terraform_remote_state.iam.outputs.cloudwatch_logs_firehose_s3.arn
  cloudwatch_firehose_role = data.terraform_remote_state.iam.outputs.cloudwatch_logs_firehose.arn
  cloudwatch_bucket        = data.terraform_remote_state.s3.outputs.cloudwatch_bucket_sin_arn
  cloudwatch_bucket_kms    = data.terraform_remote_state.kms.outputs.kms_key_s3_sin["arn"]
  lambda_processor_arn     = data.terraform_remote_state.lambda.outputs.cloudwatch_firehose_transformer.cloudwatch_firehose_lambda.lambda_function_arn
  firehose_tags = {
    env     = local.env
    purpose = "Allow cloudwatch to write logs to S3 via Kinesis Firehose"
  }

  cloudwatch_logs_prefix = {
    rds_audit   = "rds-audit"
    rds_general = "rds-general"
  }

  firehose = {
    rds_audit = {
      firehose_name           = "abex-${local.cloudwatch_logs_prefix["rds_audit"]}-${local.env}-firehose"
      firehose_role           = local.firehose_s3_role
      cloudwatch_prefix       = "${local.cloudwatch_logs_prefix["rds_audit"]}/"
      cloudwatch_bucket       = local.cloudwatch_bucket
      cloudwatch_bucket_kms   = local.cloudwatch_bucket_kms
      cloudwatch_role         = local.cloudwatch_firehose_role
      log_group_name          = "/aws/rds/cluster/exchange-aps1-staging/audit"
      log_filter_pattern      = ""
      enable_lambda_processor = true
      lambda_processor_arn    = local.lambda_processor_arn
      firehose_tags           = local.firehose_tags

    }
    rds_general = {
      firehose_name           = "abex-${local.cloudwatch_logs_prefix["rds_general"]}-${local.env}-firehose"
      firehose_role           = local.firehose_s3_role
      cloudwatch_prefix       = "${local.cloudwatch_logs_prefix["rds_general"]}/"
      cloudwatch_bucket       = local.cloudwatch_bucket
      cloudwatch_bucket_kms   = local.cloudwatch_bucket_kms
      cloudwatch_role         = local.cloudwatch_firehose_role
      log_group_name          = "/aws/rds/cluster/exchange-aps1-staging/general"
      log_filter_pattern      = ""
      enable_lambda_processor = true
      lambda_processor_arn    = local.lambda_processor_arn
      firehose_tags           = local.firehose_tags
    }
  }

}
