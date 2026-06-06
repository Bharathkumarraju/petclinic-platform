variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"

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
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Root disk size in GB for each node"
  type        = number
  default     = 20
}

variable "cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to reach the EKS API public endpoint. Restrict to your egress IPs in non-demo environments."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_sg_id" {
  description = "Security group ID of the shared ALB — used to allow NodePort traffic from ALB to nodes"
  type        = string
}

variable "addon_versions" {
  description = "Optional version pins for EKS managed add-ons. Omit or set to empty string to use the AWS default for the cluster version."
  type = object({
    coredns    = optional(string, "")
    kube_proxy = optional(string, "")
    vpc_cni    = optional(string, "")
  })
  default = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days for EKS control plane logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
