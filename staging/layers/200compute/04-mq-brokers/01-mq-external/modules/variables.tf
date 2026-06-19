variable "env" {
  description = "Define environment where MQ Broker will be hosted on"
  type        = string
  default     = null

  validation {
    condition = var.env != null ? contains(
      ["prod", "shared-resources", "external", "trusted", "network", "staging", "uat", "network-dev", "agp"],
      var.env
    ) : true
    error_message = "Environment must be one of: prod, shared-resources, trusted, network (for prod bucket) or staging, uat, network-dev (for non-prod bucket)."
  }
}

variable "broker_prefix" {
  description = "Prefix for the MQ Broker name. Must be unique within the AWS account and region."
  type        = string
  default     = null

  validation {
    condition     = var.broker_prefix != null && length(var.broker_prefix) <= 50
    error_message = "Broker name must be provided and cannot exceed 50 characters."
  }
}

variable "engine_version" {
  description = "Version of the MQ engine to use for the broker. Must be compatible with the configuration files provided."
  type        = string
  default     = "5.19.0"
}

variable "instance_type" {
  description = "The instance type for the MQ broker. Must be compatible with the chosen engine version and configuration."
  type        = string
  default     = "mq.t3.micro"
}

variable "mq_configuration_data" {
  description = "XML configuration data for the MQ broker."
  type        = string
  default     = ""
}

variable "additional_ingress_with_cidr_blocks" {
  description = "List of additional ingress rules to create where 'cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}

variable "nlb_tls_certificate_arn" {
  description = "ARN of the TLS certificate for the NLB listeners."
  type        = string
}

variable "mq_users" {
  description = "List of MQ users to create. Each user has a username, console_access flag, and groups."
  type = list(object({
    username       = string
    console_access = bool
    groups         = list(string)
  }))
  default = []
}