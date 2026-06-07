output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA trust policies"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "node_security_group_id" {
  description = "Security group ID attached to EKS nodes"
  value       = aws_security_group.node.id
}

output "eks_cluster_security_group_id" {
  description = "EKS-managed cluster security group ID — automatically attached to both control plane and all managed node group EC2 instances"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane"
  value       = aws_security_group.cluster.id
}

output "node_role_arn" {
  description = "ARN of the IAM role used by EKS nodes"
  value       = aws_iam_role.node.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for EKS control plane logs"
  value       = aws_cloudwatch_log_group.eks.name
}

output "lb_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller (annotate the kube-system SA with this)"
  value       = aws_iam_role.lb_controller.arn
}
