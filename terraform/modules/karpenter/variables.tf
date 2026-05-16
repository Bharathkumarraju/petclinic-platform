variable "cluster_name" {
  description = "Name of the EKS cluster Karpenter will manage"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA trust policy"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN used by EKS-managed nodes — Karpenter-launched nodes use the same role"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
