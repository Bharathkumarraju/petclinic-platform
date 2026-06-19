terraform {
  required_version = "~> 1.11.0"

  required_providers {
    aws = {
      version = "~> 6.32"
      source  = "hashicorp/aws"
    }
  }
}

