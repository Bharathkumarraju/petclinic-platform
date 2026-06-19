locals {
  comp_name                 = "abex"
  kms_key_alias             = "alias/kms-s3-bucket-${local.env}-sin"
  destination_access_bucket = "abex-s3-access-logs-staging"

  s3_days_until_infrequent = 180
  s3_days_until_glacier    = 365

  # Default S3_lifecycle_rule to be used for S3 bucket archival
  s3_lifecycle_rule = [
    {
      id      = "ARCHIVING"
      enabled = true

      filter = {
        # Optional, but required to avoid the warning
        prefix = "" # Can leave it empty if don't need a prefix filter
      }

      transition = [
        {
          days          = local.s3_days_until_infrequent
          storage_class = "STANDARD_IA"
        },
        {
          days          = local.s3_days_until_glacier
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  # Short S3_lifecycle_rule to be used for S3 bucket items deletion after consumption
  s3_short_lifecycle_rule = [
    {
      id      = "EXPIRE-LOGS"
      enabled = true

      filter = {
        # Optional, but required to avoid the warning
        prefix = "" # Can leave it empty if don't need a prefix filter
      }

      expiration = {
        days                         = 14
        expired_object_delete_marker = null
      }
    },
    {
      id      = "CLEANUP-DELETE-MARKERS"
      enabled = true

      filter = {
        # Optional, but required to avoid the warning
        prefix = "" # Can leave it empty if don't need a prefix filter
      }

      expiration = {
        days                         = null
        expired_object_delete_marker = true
      }
    }
  ]

  buckets_name = {
    vpc_flow_bucket_sin              = "${local.comp_name}-vpc-flow-bucket-${local.env}-sin"
    network_fw_bucket_sin            = "${local.comp_name}-network-fw-bucket-${local.env}-sin"
    lambda_bucket_sin                = "${local.comp_name}-lambda-bucket-${local.env}-sin"
    sftp_bucket_sin                  = "${local.comp_name}-sftp-bucket-${local.env}-sin"
    cronicle_bucket_sin              = "${local.comp_name}-cronicle-bucket-${local.env}-sin"
    k8sbackup_bucket_sin             = "${local.comp_name}-k8sbackup-bucket-${local.env}-sin"
    loadbalancer_bucket_sin          = "${local.comp_name}-loadbalancer-bucket-${local.env}-sin"
    rds_bucket_sin                   = "${local.comp_name}-rds-backup-${local.env}-sin"
    risk_sftp_bucket_sin             = "${local.comp_name}-sftp-bucket-risk-${local.env}-sin"
    ses_bucket_sin                   = "${local.comp_name}-ses-bucket-${local.env}-sin"
    thanos_bucket_sin                = "${local.comp_name}-thanos-bucket-${local.env}-sin"
    tempo_bucket_sin                 = "${local.comp_name}-tempo-bucket-${local.env}-sin"
    app_compliance_bucket_sin        = "${local.comp_name}-app-compliance-bucket-${local.env}-sin"
    spot_datafeed_bucket_sin         = "${local.comp_name}-spot-datafeed-bucket-${local.env}-sin"
    dsp_sftp_bucket_sin              = "${local.comp_name}-sftp-bucket-dsp-${local.env}-sin"
    route53_dns_query_bucket_sin     = "${local.comp_name}-route53-dns-query-bucket-${local.env}-sin"
    cloudwatch_bucket_sin            = "${local.comp_name}-cloudwatch-bucket-${local.env}-sin"
    marketdata_ts_db_logs_bucket_sin = "${local.comp_name}-marketdata-ts-db-logs-bucket-sin-${local.env}-sin"
    cloudfront_logs_bucket_sin       = "${local.comp_name}-cloudfront-logs-bucket-${local.env}-sin"
    adw_bucket_sin                   = "${local.comp_name}-adw-bucket-${local.env}-sin"
    acs_int_bucket_sin               = "${local.comp_name}-acs-int-bucket-${local.env}-sin"
    acs_ext_bucket_sin               = "${local.comp_name}-acs-ext-bucket-${local.env}-sin"
    swift_bucket_sin                 = "${local.comp_name}-swift-bucket-${local.env}-sin"
  }

  buckets_generic_default_encryption = {
    marketdata_ts_db_logs_bucket_sin = {
      bucket_name = local.buckets_name["marketdata_ts_db_logs_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store marketdata ts db logs"
        map-migrated = "mig46499"
      }
      region                = "sin"
      lifecycle_rule        = local.s3_short_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["marketdata_ts_db_logs_bucket_sin"]}/"
    }
  }
  buckets_generic = {
    vpc_flow_bucket_sin = {
      bucket_name = local.buckets_name["vpc_flow_bucket_sin"]
      bucket_tags = {
        purpose = "To store vpc flow logs"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["vpc_flow_bucket_sin"]}/"
    }

    network_fw_bucket_sin = {
      bucket_name = local.buckets_name["network_fw_bucket_sin"]
      bucket_tags = {
        purpose = "To store network firewall logs"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["network_fw_bucket_sin"]}/"
    }

    lambda_bucket_sin = {
      bucket_name = local.buckets_name["lambda_bucket_sin"]
      bucket_tags = {
        purpose = "To store Lambda code"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["lambda_bucket_sin"]}/"
    }

    sftp_bucket_sin = {
      bucket_name = local.buckets_name["sftp_bucket_sin"]
      bucket_tags = {
        purpose = "To store customer files"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["sftp_bucket_sin"]}/"
    }

    cronicle_bucket_sin = {
      bucket_name = local.buckets_name["cronicle_bucket_sin"]
      bucket_tags = {
        purpose = "To store cronicle data and logs"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["cronicle_bucket_sin"]}/"
    }
    dsp_sftp_bucket_sin = {
      bucket_name = local.buckets_name["dsp_sftp_bucket_sin"]
      bucket_tags = {
        purpose = "To store DSP files"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["dsp_sftp_bucket_sin"]}/"
    }
    route53_dns_query_bucket_sin = {
      bucket_name = local.buckets_name["route53_dns_query_bucket_sin"]
      bucket_tags = {
        purpose = "To store Route53 DNS query logs"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["route53_dns_query_bucket_sin"]}/"
    }
    k8sbackup_bucket_sin = {
      bucket_name = local.buckets_name["k8sbackup_bucket_sin"]
      bucket_tags = {
        purpose = "To store Helm charts"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["k8sbackup_bucket_sin"]}/"

    }
    loadbalancer_bucket_sin = {
      bucket_name = local.buckets_name["loadbalancer_bucket_sin"]
      bucket_tags = {
      purpose = "To store load balancer logs" }
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["loadbalancer_bucket_sin"]}/"
    }
    risk_sftp_bucket_sin = {
      bucket_name = local.buckets_name["risk_sftp_bucket_sin"]
      bucket_tags = {
        purpose = "To store Risk Team files"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["risk_sftp_bucket_sin"]}/"
    }
    rds_bucket_sin = {
      bucket_name = local.buckets_name["rds_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store RDS Backup files"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["rds_bucket_sin"]}/"
    }
    ses_bucket_sin = {
      bucket_name = local.buckets_name["ses_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store SES Email logs"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["ses_bucket_sin"]}/"
    }
    thanos_bucket_sin = {
      bucket_name = local.buckets_name["thanos_bucket_sin"]
      bucket_tags = {
        purpose = "To store prometheus metrics for long term storage"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["thanos_bucket_sin"]}/"
    }
    tempo_bucket_sin = {
      bucket_name = local.buckets_name["tempo_bucket_sin"]
      bucket_tags = {
        purpose = "To store traces for long term storage"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["tempo_bucket_sin"]}/"
    }
    app_compliance_bucket_sin = {
      bucket_name = local.buckets_name["app_compliance_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store App Compliance logs"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["app_compliance_bucket_sin"]}/"
    }
    spot_datafeed_bucket_sin = {
      bucket_name = local.buckets_name["spot_datafeed_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store AWS Spot Data Feed"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["spot_datafeed_bucket_sin"]}/"
    }
    cloudwatch_bucket_sin = {
      bucket_name = local.buckets_name["cloudwatch_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store RDS Logs"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_short_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["cloudwatch_bucket_sin"]}/"
    }
    cloudfront_logs_bucket_sin = {
      bucket_name = local.buckets_name["cloudfront_logs_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "To store cloudfront logs"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["cloudfront_logs_bucket_sin"]}/"
    }
    adw_bucket_sin = {
      bucket_name = local.buckets_name["adw_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "For MDIngestor worker file storage"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["adw_bucket_sin"]}/"
    }
    acs_int_bucket_sin = {
      bucket_name = local.buckets_name["acs_int_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "For ACS Internal file storage"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["acs_int_bucket_sin"]}/"
    }
    acs_ext_bucket_sin = {
      bucket_name = local.buckets_name["acs_ext_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "For ACS External file storage"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["acs_ext_bucket_sin"]}/"
    }
    swift_bucket_sin = {
      bucket_name = local.buckets_name["swift_bucket_sin"]
      bucket_tags = {
        env          = "${local.env}"
        purpose      = "For Swift file storage testing purpose for new ACS"
        map-migrated = "mig46499"
      }
      kms_key_alias         = "alias/kms-s3-bucket-${local.env}-sin"
      region                = "sin"
      lifecycle_rule        = local.s3_lifecycle_rule
      access_logging_bucket = local.destination_access_bucket
      logging_prefix        = "logs/${local.buckets_name["swift_bucket_sin"]}/"
    }
  }
}