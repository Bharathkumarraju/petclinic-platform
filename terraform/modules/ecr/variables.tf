variable "service_names" {
  description = "List of service names — one ECR repository is created per service"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Tag mutability setting: MUTABLE allows tag overwrites, IMMUTABLE prevents them"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
