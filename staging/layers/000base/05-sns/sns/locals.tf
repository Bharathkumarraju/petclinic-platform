locals {
  sns_topic_prefix = {
    #Structured to add more kinds of sns for different services
    alerts_slack     = "alerts-slack"
    alerts_pagerduty = "pagerduty"
    clara            = "clara"
    eprime           = "eprime"
    exberry          = "exberry"
  }

  pagerduty_common_services_map            = {
    # tier 1 - business applications
    "clara"            = "Abaxx Clearing System (ACS) / Clara"
    "clara-eod-jobs"   = "End of day jobs to support Clara systems"
    "atrp"           = "Abaxx Trade Reporting Platform (ATRP) / ePrime"
    "exberry-dsp-jobs" = "Exberry Daily Settlement Price (DSP) jobs"
    "mdapi"            = "Market Data API"
    "dms"              = "AWS Database Migration Service jobs"
    # tier 2 - supporting applications
    "rds-backups" = "MySQL level backup jobs"
    "risk"        = "Risk services"
    "swift-sync"  = "Custom SWIFT message sync running on K8s Cron Job"
    # infrastructure
    "backup"           = "AWS Backup Service"
    "amazonmq"         = "AWS Managed Message Queue service"
    "ec2"              = "AWS Elastic Cloud Compute service"
    "rds"              = "AWS Relational Databse Service"
    "transfer-service" = "AWS Transfer Family services"
  }

  sns_topics = {
    alerts_slack_sin = {
      topic_name = "${local.sns_topic_prefix["alerts_slack"]}-${local.env}-sin"
      topic_tags = {
        purpose = "For sending Alerts to Slack"
      }
      topic_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_sns_sin["key_id"]
    }
    alerts_pagerduty_sin = {
      topic_name = "${local.sns_topic_prefix["alerts_pagerduty"]}-${local.env}-sin"
      topic_tags = {
        purpose = "For sending Alerts to pagerduty"
      }
      topic_encrypt_key = data.terraform_remote_state.kms.outputs.kms_key_sns_sin["key_id"]
    }

  }
}
