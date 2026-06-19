data "aws_partition" "current" {}
data "terraform_remote_state" "kms_secrets_manager" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/secrets_manager/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "s3_kms" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/s3_bucket/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
