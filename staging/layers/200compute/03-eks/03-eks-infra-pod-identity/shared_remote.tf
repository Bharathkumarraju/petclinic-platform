data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}

data "aws_availability_zones" "all" {
  state = "available"
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

data "terraform_remote_state" "ebs-kms-keys" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/ec2_ebs/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "kms_cloudwatch_logs" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/cloudwatch_logs/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "kms_s3_bucket" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/s3_bucket/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###### Reading TF state for network layer parameters #######

# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = "abaxx-exch-tf-state-nonprod"
#     key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

# data "terraform_remote_state" "network-layer-1" {
#   backend = "s3"
#   config = {
#     bucket = "abaxx-exch-tf-state-nonprod"
#     key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-1/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

data "terraform_remote_state" "bucket" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/03-bucket/terraform.tfstate"
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

data "terraform_remote_state" "eks_base" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/200compute/03-eks/02-eks-base/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "kms_secrets_manager" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/secrets_manager/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
