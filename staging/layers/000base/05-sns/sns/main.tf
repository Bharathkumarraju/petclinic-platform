module "alerts_to_slack_sin" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  use_name_prefix   = false
  name              = lookup(local.sns_topics["alerts_slack_sin"], "topic_name")
  display_name      = lookup(local.sns_topics["alerts_slack_sin"], "topic_name")
  tags              = lookup(local.sns_topics["alerts_slack_sin"], "topic_tags")
  kms_master_key_id = lookup(local.sns_topics["alerts_slack_sin"], "topic_encrypt_key")
  # fifo_topic                  = true
  # content_based_deduplication = true
}


module "alerts_to_pagerduty_sin" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  use_name_prefix   = false
  name              = lookup(local.sns_topics["alerts_pagerduty_sin"], "topic_name")
  display_name      = lookup(local.sns_topics["alerts_pagerduty_sin"], "topic_name")
  tags              = lookup(local.sns_topics["alerts_pagerduty_sin"], "topic_tags")
  kms_master_key_id = lookup(local.sns_topics["alerts_pagerduty_sin"], "topic_encrypt_key")
  # fifo_topic                  = true
  # content_based_deduplication = true
}

// Pagerduty SNS Topics
module "cloudwatch_to_pagerduty_sin" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  for_each = local.pagerduty_common_services_map

  use_name_prefix = false
  name            = "pagerduty-${each.key}-${local.env}-sin"
  display_name    = "pagerduty-${each.key}-${local.env}-sin"
  tags = {
    purpose = "For sending Alerts to pagerduty for ${local.env}_${each.key} service"
  }
  kms_master_key_id = data.terraform_remote_state.kms.outputs.kms_key_sns_sin["key_id"]
  # fifo_topic                  = true
  # content_based_deduplication = true
}
