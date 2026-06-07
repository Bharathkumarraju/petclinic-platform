output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "Node security group ID"
  value       = module.eks.node_security_group_id
}

output "lb_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller — annotate kube-system/aws-load-balancer-controller SA with this"
  value       = module.eks.lb_controller_role_arn
}
