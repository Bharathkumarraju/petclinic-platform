terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/03-eks/02-eks-base/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
