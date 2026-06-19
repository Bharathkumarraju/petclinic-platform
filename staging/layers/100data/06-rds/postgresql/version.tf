terraform {
  required_version = "~> 1.12.2"

  required_providers {
    aws = {
      version = "~> 6.0"
      source  = "hashicorp/aws"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25.0"
    }
  }
}


# Placing this here as the provider.tf is symlinked
# TODO: update to use IAM authentication through TF Role
provider "postgresql" {
  host                          = split(":", module.postgres.db_instance_endpoint)[0]
  port                          = 5432
  database                      = "postgres"
  username                      = module.postgres.db_instance_username
  aws_rds_iam_auth              = true
  aws_rds_iam_provider_role_arn = "arn:aws:iam::993533333148:role/abaxx-exch-terraform-provisioner"

  sslmode         = "require"
  connect_timeout = 15

  superuser = false
}

ephemeral "aws_secretsmanager_secret_version" "sharedpsql_password" {
  secret_id = module.postgres.db_instance_master_user_secret_arn
}


