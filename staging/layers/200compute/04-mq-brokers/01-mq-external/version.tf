terraform {
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      version = "~> 6.40"
      source  = "hashicorp/aws"
    }
  }
}

