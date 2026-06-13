variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "openai_api_key" {
  description = "OpenAI API key for the GenAI service — pass via TF_VAR_openai_api_key, never commit"
  type        = string
  sensitive   = true
}
