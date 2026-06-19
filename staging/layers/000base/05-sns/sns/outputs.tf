output "alerts_to_slack_id_sin" {
  description = "SNS Topic to send alerts to Slack"
  value       = module.alerts_to_slack_sin.topic_id
}

output "alerts_to_slack_topic_name_sin" {
  description = "SNS Topic to send alerts to Slack"
  value       = module.alerts_to_slack_sin.topic_name
}


output "alerts_to_pagerduty_id_sin" {
  description = "SNS Topic to send alerts to Pagerduty"
  value       = module.alerts_to_pagerduty_sin.topic_id
}

output "alerts_to_pagerduty_topic_name_sin" {
  description = "SNS Topic to send alerts to Pagerduty"
  value       = module.alerts_to_pagerduty_sin.topic_name
}

output "cloudwatch_to_pagerduty_sin" {
  description = "SNS Topic to send alerts to Pagerduty"
  value       = module.cloudwatch_to_pagerduty_sin
}
