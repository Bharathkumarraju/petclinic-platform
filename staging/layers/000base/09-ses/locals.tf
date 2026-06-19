locals {
  firehose_s3_role  = data.terraform_remote_state.iam.outputs.ses_logs_firehose_s3.arn
  ses_firehose_role = data.terraform_remote_state.iam.outputs.ses_logs_ses_firehose.arn
  ses_bucket        = data.terraform_remote_state.s3.outputs.ses_bucket_sin
  ses_bucket_kms    = data.terraform_remote_state.kms.outputs.kms_key_s3_sin["arn"]
  ses_prefix        = "abex-ses"

  ses_logs_s3 = {
    config_set_name       = "${local.ses_prefix}-${local.env}-config-set"
    kinesis_fh_name       = "${local.ses_prefix}-${local.env}-kinesis-fh"
    kinesis_role          = local.firehose_s3_role
    config_set_event_dest = "${local.ses_prefix}-${local.env}-config-set-event-dest"
    ses_role              = local.ses_firehose_role
    ses_bucket            = local.ses_bucket
    ses_bucket_kms        = local.ses_bucket_kms
    config_set_tags = {
      env          = local.env
      purpose      = "Allow SES to write logs to S3 via Kinesis Firehose"
      map-migrated = "mig46499"
    }
  }

  # Define your SES domain identities here
  # Add domains that you want to verify and use with SES
  ses_domains = [
    "clearing.staging.abaxx.exchange",            # New ACS
    "marketdata-internal.staging.abaxx.exchange", # MDingestor Service
    "acer.staging.abaxx.exchange", # AcerReport Service
    # Example: "example.com",
    # Example: "mail.example.com",
  ]

}
