terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Bucket must be pre-created by scripts/bootstrap-state.sh
    bucket       = "petclinic-terraform-state-bkr"
    key          = "petclinic/shared/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "petclinic"
      Environment = "shared"
      ManagedBy   = "terraform"
    }
  }
}
