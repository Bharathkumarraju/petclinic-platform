
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "all" {

  state = "available"
}
###### Reading TF state for MQ KMS Key #######

data "terraform_remote_state" "kms-keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/amazon_mq/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for secrets KMS Keys #######

data "terraform_remote_state" "secrets-kms-keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/secrets_manager/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for network (VPC, subnet) #######

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for MQ Security group #######

data "terraform_remote_state" "mq-sg" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-1/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for cloudwatch KMS key #######

data "terraform_remote_state" "cloudwatch_keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/02-cloudwatch/terraform.tfstate"
    region = "ap-southeast-1"
  }
}


###### Reading TF state for IAM Services #######

data "terraform_remote_state" "iam_services" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/04-iam-services/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "rds-kms" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/rds_database/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
data "aws_kms_key" "rds_kms_key" {
  key_id = data.terraform_remote_state.rds-kms.outputs.kms_key_rds_sin["rds_db_sin"].key_id
}
data "aws_secretsmanager_secret" "risk-db-creds" {
  name = "${local.env}/risk-db-creds"
}

data "aws_secretsmanager_secret_version" "risk-db-creds" {
  secret_id = data.aws_secretsmanager_secret.risk-db-creds.id
}
data "aws_kms_key" "risk-db-creds" {
  key_id = data.aws_secretsmanager_secret.risk-db-creds.kms_key_id
}

data "aws_secretsmanager_secret" "risk-user-creds" {
  name = "${local.env}/risk-user-creds"
}

data "aws_secretsmanager_secret_version" "risk-user-creds" {
  secret_id = data.aws_secretsmanager_secret.risk-user-creds.id
}
data "aws_kms_key" "risk-user-creds" {
  key_id = data.aws_secretsmanager_secret.risk-user-creds.kms_key_id
}

// riskviewer

data "aws_secretsmanager_secret" "risk-viewer-creds" {
  name = "${local.env}/risk-viewer-creds"
}

data "aws_secretsmanager_secret_version" "risk-viewer-creds" {
  secret_id = data.aws_secretsmanager_secret.risk-viewer-creds.id
}
