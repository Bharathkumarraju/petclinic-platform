output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "node_groups" {
  description = "Map of mesh name to node group name"
  value       = { for k, v in aws_eks_node_group.mesh : k => v.node_group_name }
}

output "node_security_group_id" {
  description = "Security group ID attached to EKS nodes"
  value       = aws_security_group.node.id
}

output "kubeconfig_command" {
  description = "Command to update local kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region eu-central-1 --alias eks-servicemesh"
}
