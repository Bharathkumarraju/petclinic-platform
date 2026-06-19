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
  host      = data.aws_db_instance.dsp.address
  port      = data.aws_db_instance.dsp.port
  username  = data.aws_db_instance.dsp.master_username
  password  = jsondecode(data.aws_secretsmanager_secret_version.dsp_master.secret_string)["password"]
  database  = "postgres"
  sslmode   = "require"
  superuser = false
}
