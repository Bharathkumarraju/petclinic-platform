terraform {
  required_version = "~> 1.11.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "< 3.0"
    }
    aws = {
      version = "~> 5.9"
      source = "hashicorp/aws"
    }
  }
}

