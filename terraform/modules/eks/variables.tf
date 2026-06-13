variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "kubernetes_version must be in MAJOR.MINOR format (e.g. 1.31)."
  }
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster and managed node group"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t4g.small"]
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 8
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 8
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 9
}

variable "node_disk_size" {
  description = "Root disk size in GB for each node"
  type        = number
  default     = 20
}

variable "node_ami_release_version" {
  description = "AMI release version for the managed node group (e.g. 1.33.0-20250501). Leave empty to let AWS pick the latest for the cluster version. Must be updated in lockstep with kubernetes_version when upgrading."
  type        = string
  default     = ""
}

variable "cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "addon_versions" {
  description = "Optional version pins for EKS managed add-ons. Omit or set to empty string to use the AWS default for the cluster version."
  type = object({
    coredns    = optional(string, "")
    kube_proxy = optional(string, "")
    vpc_cni    = optional(string, "")
    ebs_csi    = optional(string, "")
  })
  default = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days for EKS control plane logs"
  type        = number
  default     = 7
}

variable "admin_arns" {
  description = "IAM principal ARNs granted cluster-admin access via EKS access entries"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
