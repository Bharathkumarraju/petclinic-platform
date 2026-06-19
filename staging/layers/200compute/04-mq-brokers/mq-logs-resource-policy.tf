resource "aws_cloudwatch_log_resource_policy" "mq_logs" {
  policy_name     = "AmazonMQ-Logs-${local.env}-sin"
  policy_document = file("${path.module}/configuration_files/mq-logs-policy.json")
}

