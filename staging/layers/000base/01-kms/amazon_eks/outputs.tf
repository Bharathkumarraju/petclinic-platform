output "kms_key_eks_sin" {
  description = "KMS for encrypting EKS CLuster"
  value       = module.eks-cluster-sin.kms_key
}

output "kms_key_eks_alias_sin" {
  description = "KMS Key Alias for EKS cluster Key"
  value       = module.eks-cluster-sin.kms_key_alias
}
