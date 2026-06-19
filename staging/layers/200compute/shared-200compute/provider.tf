provider "aws" {
  region = "ap-southeast-1"
  assume_role {
    role_arn = local.role_arn
  }
  default_tags {
    tags = {
      env          = local.env
      map-migrated = "mig46499"
    }
  }
}

provider "aws" {
  alias  = "sin"
  region = "ap-southeast-1"
  assume_role {
    role_arn = local.role_arn
  }
  default_tags {
    tags = {
      env          = local.env
      map-migrated = "mig46499"
    }
  }
}

provider "aws" {
  alias  = "vir"
  region = "us-east-1"
  assume_role {
    role_arn = local.role_arn
  }
  default_tags {
    tags = {
      env          = local.env
      map-migrated = "mig46499"
    }
  }
}