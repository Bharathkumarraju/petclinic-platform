variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "state_bucket" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
  default     = "petclinic-terraform-state-bkr"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "admin_arns" {
  description = "IAM principal ARNs granted cluster-admin access via EKS access entries"
  type        = list(string)
  default     = ["arn:aws:iam::172586632398:user/bharath"]
}

variable "node_ami_release_version" {
  description = "AMI release version for managed node group. Empty string lets AWS pick the latest for the cluster version. Update in lockstep with kubernetes_version when upgrading."
  type        = string
  default     = ""
}
