output "karpenter_role_arn" {
  description = "IRSA role ARN for the Karpenter controller service account"
  value       = aws_iam_role.karpenter.arn
}

output "karpenter_queue_name" {
  description = "SQS queue name for Spot interruption and rebalance events"
  value       = aws_sqs_queue.karpenter.name
}

output "karpenter_instance_profile_name" {
  description = "IAM instance profile name for Karpenter-launched nodes"
  value       = aws_iam_instance_profile.karpenter_node.name
}
