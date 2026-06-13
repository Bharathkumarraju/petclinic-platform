variable "project" {
  description = "Project name prefix used in secret names"
  type        = string
  default     = "petclinic"
}

variable "openai_api_key" {
  description = "OpenAI API key value to store in Secrets Manager — pass via TF_VAR_openai_api_key, never hardcode"
  type        = string
  sensitive   = true

  validation {
    condition     = length(trimspace(var.openai_api_key)) > 0
    error_message = "openai_api_key must not be empty or whitespace."
  }
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
