terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/100data/06-rds/rds-acerreport-postgresql/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
