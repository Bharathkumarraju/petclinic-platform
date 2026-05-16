variable "cluster_name" {
  description = "Name of the EKS cluster this observability stack serves"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA trust policies"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL (without https://) for IRSA condition keys"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
