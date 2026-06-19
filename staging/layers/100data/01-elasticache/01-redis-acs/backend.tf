terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/100data/01-elasticache/01-redis-acs/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
