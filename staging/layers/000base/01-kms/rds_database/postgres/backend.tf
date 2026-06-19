terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/01-kms/rds_database/postgres/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
