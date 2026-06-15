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

variable "node_instance_type" {
  description = "EC2 instance type for all mesh node groups"
  type        = string
  default     = "t4g.small"
}

variable "node_ami_release_version" {
  description = "AMI release version for managed node groups. Empty string lets AWS pick the latest for the cluster version."
  type        = string
  default     = "1.33.11-20260529"
}
