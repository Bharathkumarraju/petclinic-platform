data "terraform_remote_state" "secrets-kms-keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/secrets_manager/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
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

data "aws_region" "current" {
}

data "aws_db_instance" "dsp" {
  db_instance_identifier = local.db_identifier
}

data "aws_secretsmanager_secret_version" "dsp_master" {
  secret_id = data.aws_db_instance.dsp.master_user_secret[0].secret_arn
}
