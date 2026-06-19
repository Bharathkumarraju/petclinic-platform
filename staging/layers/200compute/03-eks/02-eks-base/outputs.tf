
# output "eks_cluster_endpoint" {
#   description = "EKS Cluster Endpoint"
#   value       = module.eks.cluster_endpoint
# }

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

# output "eks_cluster_id" {
#   description = "EKS Cluster ID"
#   value       = module.eks.cluster_id
# }

# output "eks_cluster_version" {
#   description = "EKS Cluster VERSION"
#   value       = module.eks.cluster_version
# }

output "eks_oidc_provider" {
  description = "EKS OIDC Provider"
  value       = module.eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

# output "eks_cluster_certificate_authority_data" {
#   description = "EKS Cluster CA"
#   value       = module.eks.cluster_certificate_authority_data
# }

output "eks_cluster" {
  description = "EKS Cluster Outputs"
  value       = module.eks
}

# output "eks_blueprints_addons" {
#   description = "EKS Blueprint addons"
#   value       = module.eks_blueprints_addons
# }

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN for the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}