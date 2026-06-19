
resource "aws_ses_configuration_set" "ses_config_set" {
  name                       = local.ses_logs_s3["config_set_name"]
  reputation_metrics_enabled = true
}

resource "aws_kinesis_firehose_delivery_stream" "ses_logs_kinesis_fh" {
  name        = local.ses_logs_s3["kinesis_fh_name"]
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn    = local.ses_logs_s3["kinesis_role"]
    bucket_arn  = "arn:aws:s3:::${local.ses_logs_s3["ses_bucket"]}"
    kms_key_arn = local.ses_logs_s3["ses_bucket_kms"]
    prefix      = "${local.ses_logs_s3["config_set_name"]}/"
  }
  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = local.ses_logs_s3["ses_bucket_kms"]
  }
  tags = local.ses_logs_s3["config_set_tags"]
}

resource "aws_ses_event_destination" "ses_logs_event" {
  name                   = local.ses_logs_s3["config_set_event_dest"]
  configuration_set_name = aws_ses_configuration_set.ses_config_set.name
  enabled                = true

  matching_types = [
    "send",
    "reject",
    "bounce",
    "complaint",
    "delivery"
  ]

  kinesis_destination {
    stream_arn = resource.aws_kinesis_firehose_delivery_stream.ses_logs_kinesis_fh.arn
    role_arn   = local.ses_logs_s3["ses_role"]
  }
}

# SES Domain Identities
resource "aws_ses_domain_identity" "domain" {
  for_each = toset(local.ses_domains)
  domain   = each.value
}

# SES Domain DKIM - for email authentication
resource "aws_ses_domain_dkim" "domain" {
  for_each = aws_ses_domain_identity.domain
  domain   = each.value.domain
}

# SES Custom MAIL FROM Domain
# Sets "ses.<domain>" as the MAIL FROM subdomain for each identity
resource "aws_ses_domain_mail_from" "domain" {
  for_each = aws_ses_domain_identity.domain

  domain           = each.value.domain
  mail_from_domain = "ses.${each.value.domain}"
}