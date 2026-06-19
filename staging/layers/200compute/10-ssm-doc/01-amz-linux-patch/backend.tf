terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/10-ssm-doc/01-amz-linux-patch/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
