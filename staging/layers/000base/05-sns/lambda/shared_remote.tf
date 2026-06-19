data "terraform_remote_state" "kms" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/sns/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "sns" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/05-sns/sns/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "cloudwatch" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/02-cloudwatch/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/04-iam-services/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "lambda_layers" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/04a-lambda-layers/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
