variable "project" {
  description = "Project name prefix used in secret names"
  type        = string
  default     = "petclinic"
}

variable "openai_api_key" {
  description = "OpenAI API key value to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
