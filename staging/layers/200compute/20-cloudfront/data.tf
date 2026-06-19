data "terraform_remote_state" "bucket" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/03-bucket/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "web-acl" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-waf/web-acl/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/12-acm/terraform.tfstate"
    region = "ap-southeast-1"
  }
}