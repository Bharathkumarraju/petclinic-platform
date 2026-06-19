locals {
  sqs_name       = "abex"
  kms_key_sqs_id = data.terraform_remote_state.kms.outputs.kms_key_sqs_sin.arn

  # S3 buckets
  elb_s3_bucket = data.terraform_remote_state.s3.outputs.loadbalancer_bucket_sin_name
  ses_s3_bucket = data.terraform_remote_state.s3.outputs.ses_bucket_sin
  vpc_s3_bucket = data.terraform_remote_state.s3.outputs.vpc_flow_bucket_sin_name
  nfw_s3_bucket = data.terraform_remote_state.s3.outputs.network_fw_bucket_sin_name
  r53_s3_bucket = data.terraform_remote_state.s3.outputs.route53_dns_query_bucket_sin_name
  cw_s3_bucket  = data.terraform_remote_state.s3.outputs.cloudwatch_bucket_sin_name
  marketdata_ts_db_logs_bucket = data.terraform_remote_state.s3.outputs.marketdata_ts_db_logs_bucket_sin_name

  s3_notification_policy = jsondecode(file("common-policies/default_s3_notification.json"))

  queue_name = {
    elastic_elb            = "${local.sqs_name}-elastic-elb-${local.env}-sin"
    elastic_ses            = "${local.sqs_name}-elastic-ses-${local.env}-sin"
    elastic_vpc            = "${local.sqs_name}-elastic-vpc-${local.env}-sin"
    elastic_nfw            = "${local.sqs_name}-elastic-nfw-${local.env}-sin"
    elastic_r53            = "${local.sqs_name}-elastic-r53-${local.env}-sin"
    elastic_cw_rds_audit   = "${local.sqs_name}-elastic-cw-rds-audit-${local.env}-sin"
    elastic_cw_rds_general = "${local.sqs_name}-elastic-cw-rds-general-${local.env}-sin"
    elastic_marketdata_ts_db_logs = "${local.sqs_name}-elastic-marketdata-ts-db-logs-${local.env}-sin"
  }

  sqs_queue = {
    elastic_elb = {
      sqs_name                    = local.queue_name["elastic_elb"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.elb_s3_bucket
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get data from ELB S3"
      }
    }

    elastic_ses = {
      sqs_name                    = local.queue_name["elastic_ses"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.ses_s3_bucket
      bucket_list_prefix = [
        "abex-ses-staging-config-set/",
      ]
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get data from SES S3"
      }
    }

    elastic_vpc = {
      sqs_name                    = local.queue_name["elastic_vpc"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.vpc_s3_bucket
      bucket_list_prefix = [
        "AWSLogs/",
      ]
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get data from VPC Flow Logs S3"
      }
    }

    elastic_nfw = {
      sqs_name                    = local.queue_name["elastic_nfw"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.nfw_s3_bucket
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get data from Network Firewall Logs S3"
      }
    }

    elastic_r53 = {
      sqs_name                    = local.queue_name["elastic_r53"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.r53_s3_bucket
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get data from Route53 DNS Query logs S3"
      }
    }

    elastic_cw_rds_audit = {
      sqs_name                    = local.queue_name["elastic_cw_rds_audit"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.cw_s3_bucket
      bucket_list_prefix = [
        "rds-audit/",
      ]
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get rds-audit data from Cloudwatch logs S3"
      }
    }
    elastic_cw_rds_general = {
      sqs_name                    = local.queue_name["elastic_cw_rds_general"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.cw_s3_bucket
      bucket_list_prefix = [
        "rds-general/",
      ]
      sqs_tags = {
        purpose = "SQS for Elastic Agent to get rds-general data from Cloudwatch logs S3"
      }
    }
    elastic_marketdata_ts_db_logs = {
      sqs_name                    = local.queue_name["elastic_marketdata_ts_db_logs"]
      sqs_kms_key                 = local.kms_key_sqs_id
      content_based_deduplication = true
      create_queue_policy         = true
      sqs_policy                  = local.s3_notification_policy
      visibility_timeout_seconds  = 910
      s3_bucket                   = local.marketdata_ts_db_logs_bucket
      bucket_list_prefix = [
        "InfluxLogs/marketdata-aps1-staging/9kf14tas30/",
      ]
        sqs_tags = {
          purpose = "SQS for Elastic Agent to get MarketData Timestream Database logs from S3"
        }
    }
  }
}
