terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/100data/04-aurora/aurora-mysql-risk/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
