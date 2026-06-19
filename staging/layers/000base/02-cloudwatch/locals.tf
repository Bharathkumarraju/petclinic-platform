locals {
  region        = "ap-southeast-1"
  region_parts  = split("-", local.region)
  region_prefix = join("", [local.region_parts[0], substr(local.region_parts[1], 0, 1), local.region_parts[2]])
  clara_db_name = "clarity"
  envoy_db_name = "eprime"
  cloudwatch_prefix = {
    #Structured to add more kinds of logs for different services
    #  vpc_flow_log                 = "/aws/vpc-flow-log"
    lambda_notify_slack_log      = "/aws/lambda/alerts-slack"
    cloudwatch_s3_log            = "/aws/lambda/cloudwatch-logs-to-s3"
    cloudwatch_firehose_log      = "/aws/lambda/cloudwatch-firehose"
    # ec2_ubuntu_auth_log          = "/aws/ec2/ubuntu/auth"
    # ec2_ubuntu_syslog_log        = "/aws/ec2/ubuntu/syslog"
    # ec2_amazonlinux_secure_log   = "/aws/ec2/amazonlinux/secure"
    # ec2_amazonlinux_messages_log = "/aws/ec2/amazonlinux/messages"
    swift_sync_log               = "/app/${local.env}/swift-sync"
    # clara_finance_reports_log    = "/app/${local.env}/clara-finance-reports"
    # clara_span_reports_log       = "/app/${local.env}/clara-span-reports"
    # exberry_md_collection_log    = "/app/${local.env}/exberry-md-collection"
    # exberry_dsp_update_log       = "/app/${local.env}/exberry-dsp-update"
    # exberry_bootstrapping_log    = "/app/${local.env}/exberry-bootstrapping"
    # risk_dsp_log                 = "/app/${local.env}/pod/riskdsp"
    # risk_dashboard_log           = "/app/${local.env}/pod/riskdashboard"
    # mdapi_log                    = "/app/${local.env}/pod/mdapi"
    # mmtapi_log                   = "/app/${local.env}/pod/mmtapi"
  }

  cloudwatch_rds_prefix = {
    #Structured to add more kinds of logs for different services
    rds_database_log = "/aws/rds/cluster"
  }

  cloudwatch_log_groups = {
    # main_vpc_flow_log_sin = {
    #   cloudwatch_log = "${local.cloudwatch_prefix["vpc_flow_log"]}/${local.env}/sin/main_vpc"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "Main VPC Flow Log Sin"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }

    lambda_notify_slack_log_sin = {
      cloudwatch_log = "${local.cloudwatch_prefix["lambda_notify_slack_log"]}-${local.env}-sin"
      log_tags = {
        env     = local.env
        purpose = "Lambda Notify Slack Log Sin"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }

    cloudwatch_s3_log_sin = {
      cloudwatch_log = "${local.cloudwatch_prefix["cloudwatch_s3_log"]}-${local.env}-sin"
      log_tags = {
        env     = local.env
        purpose = "Lambda Notify Cloudwatch Backup Log Sin"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }

    cloudwatch_firehose_log_sin = {
      cloudwatch_log = "${local.cloudwatch_prefix["cloudwatch_firehose_log"]}-${local.env}-sin"
      log_tags = {
        env     = local.env
        purpose = "Lambda Cloudwatch Firehose Log Sin"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }

    # ec2_ubuntu_auth_log = {
    #   cloudwatch_log = "${local.cloudwatch_prefix["ec2_ubuntu_auth_log"]}"
    #   log_tags = {
    #     env          = local.env
    #     map-migrated = "mig46499"
    #     purpose      = "EC2 Ubuntu Auth Log"
    #     ExportToS3   = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # ec2_ubuntu_syslog_log = {
    #   cloudwatch_log = "${local.cloudwatch_prefix["ec2_ubuntu_syslog_log"]}"
    #   log_tags = {
    #     env          = local.env
    #     map-migrated = "mig46499"
    #     purpose      = "EC2 Ubuntu Syslog Log"
    #     ExportToS3   = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # ec2_amazonlinux_secure_log = {
    #   cloudwatch_log = "${local.cloudwatch_prefix["ec2_amazonlinux_secure_log"]}"
    #   log_tags = {
    #     env          = local.env
    #     map-migrated = "mig46499"
    #     purpose      = "EC2 Amazonlinux Secure Log"
    #     ExportToS3   = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # ec2_amazonlinux_messages_log = {
    #   cloudwatch_log = "${local.cloudwatch_prefix["ec2_amazonlinux_messages_log"]}"
    #   log_tags = {
    #     env          = local.env
    #     map-migrated = "mig46499"
    #     purpose      = "EC2 Amazonlinux Messages Log"
    #     ExportToS3   = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    swift_sync_log = {
      cloudwatch_log = "${local.cloudwatch_prefix["swift_sync_log"]}"
      log_tags = {
        env          = local.env
        map-migrated = "mig46499"
        purpose      = "Swift Sync Application Log"
        ExportToS3   = "true"
      }
      cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    }
  #   clara_finance_reports_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["clara_finance_reports_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "Clara Reports export to finance Log"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   clara_span_reports_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["clara_span_reports_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "Clara SPAN Report export to Market Participants and Risk Team"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   exberry_md_collection_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["exberry_md_collection_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "Exberry Reports"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   exberry_dsp_update_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["exberry_dsp_update_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "Exberry dsp_update"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   exberry_bootstrapping_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["exberry_bootstrapping_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "Exberry bootstrapping"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }

  #   risk_dsp_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["risk_dsp_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "risk dsp"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   risk_dashboard_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["risk_dashboard_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "risk dashboard"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   mdapi_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["mdapi_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "market data api"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }
  #   mmtapi_log = {
  #     cloudwatch_log = "${local.cloudwatch_prefix["mmtapi_log"]}"
  #     log_tags = {
  #       env          = local.env
  #       map-migrated = "mig46499"
  #       purpose      = "market maker measurement api"
  #       ExportToS3   = "true"
  #     }
  #     cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
  #   }

  # }

  # cloudwatch_rds_log_groups = {
    # envoy_postgres_cloudwatch_log_postgresql_sin = {
    #   cloudwatch_log = "${local.cloudwatch_rds_prefix["rds_database_log"]}/${local.envoy_db_name}-${local.region_prefix}-${local.env}/postgresql"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "postgres envoy DB cloudwatch log"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # envoy_postgres_cloudwatch_log_upgrade_sin = {
    #   cloudwatch_log = "${local.cloudwatch_rds_prefix["rds_database_log"]}/${local.envoy_db_name}-${local.region_prefix}-${local.env}/upgrade"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "postgres envoy DB cloudwatch log"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # clarity_mysql_cloudwatch_log_general_sin = {
    #   cloudwatch_log = "${local.cloudwatch_rds_prefix["rds_database_log"]}/${local.clara_db_name}-${local.region_prefix}-${local.env}/general"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "mysql clarity DB cloudwatch log"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # clarity_mysql_cloudwatch_log_audit_sin = {
    #   cloudwatch_log = "${local.cloudwatch_rds_prefix["rds_database_log"]}/${local.clara_db_name}-${local.region_prefix}-${local.env}/audit"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "mysql clarity DB cloudwatch log"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # clarity_mysql_cloudwatch_log_slowquery_sin = {
    #   cloudwatch_log = "${local.cloudwatch_rds_prefix["rds_database_log"]}/${local.clara_db_name}-${local.region_prefix}-${local.env}/slowquery"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "mysql clarity DB cloudwatch log"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
    # clarity_mysql_cloudwatch_log_error_sin = {
    #   cloudwatch_log = "${local.cloudwatch_rds_prefix["rds_database_log"]}/${local.clara_db_name}-${local.region_prefix}-${local.env}/error"
    #   log_tags = {
    #     env        = local.env
    #     purpose    = "mysql clarity DB cloudwatch log"
    #     ExportToS3 = "true"
    #   }
    #   cloudwatch_logs_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_cloudwatch_logs_sin["arn"]
    # }
  }
}

