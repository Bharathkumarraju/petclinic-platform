terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/10-cloudwatch-to-firehose/cloudwatch-to-firehose/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
