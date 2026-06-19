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

provider "postgresql" {
  host      = data.aws_db_instance.instrumentgenerator.address
  port      = data.aws_db_instance.instrumentgenerator.port
  username  = data.aws_db_instance.instrumentgenerator.master_username
  password  = jsondecode(data.aws_secretsmanager_secret_version.instrumentgenerator_master.secret_string)["password"]
  database  = "postgres"
  sslmode   = "require"
  superuser = false
}
