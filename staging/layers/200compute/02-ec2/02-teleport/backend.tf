terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/02-ec2/02-teleport/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
