terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/100data/05-clara-dms-sync/clara-risk-sync/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
