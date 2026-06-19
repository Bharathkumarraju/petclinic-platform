data "terraform_remote_state" "network-pre" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-pre/terraform.tfstate"
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

data "terraform_remote_state" "transit-gw-dev" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-cross-transit-gw/environments/aws-network-dev/sin/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
