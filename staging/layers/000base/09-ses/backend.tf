terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/09-ses/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
