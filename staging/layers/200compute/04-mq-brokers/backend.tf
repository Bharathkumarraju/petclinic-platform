terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/04-mq-brokers/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
