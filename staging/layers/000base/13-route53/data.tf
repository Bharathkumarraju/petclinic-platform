# Remote state for SES configuration
data "terraform_remote_state" "ses" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/09-ses/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Remote state for ACM certificates
data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/12-acm/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Remote state for Global Accelerator Dev
data "terraform_remote_state" "global_accelerator" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-network-dev/layers/200compute/21-global-accelerator/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Remote state for Cloudfront Distributions
data "terraform_remote_state" "cloudfront" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/200compute/20-cloudfront/terraform.tfstate"
    region = "ap-southeast-1"
  }
}