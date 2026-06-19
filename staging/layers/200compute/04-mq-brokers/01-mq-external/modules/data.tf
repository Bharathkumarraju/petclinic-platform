data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = local.bucket_name
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "kms_mq" {
  backend = "s3"
  config = {
    bucket = local.bucket_name
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/amazon_mq/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = local.bucket_name
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/03-bucket/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "core_network" {
  backend = "s3"
  config = {
    bucket = local.bucket_name
    key    = "abaxxsingapore/abex-aws-env-${local.network_state_key}/layers/000base/06-network/layer-0/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_network_interfaces" "mq_nlb" {
  filter {
    name   = "description"
    values = ["ELB ${aws_lb.mq_nlb.arn_suffix}"]
  }
}

data "aws_network_interface" "mq_nlb" {
  for_each = toset(data.aws_network_interfaces.mq_nlb.ids)
  id       = each.value
}