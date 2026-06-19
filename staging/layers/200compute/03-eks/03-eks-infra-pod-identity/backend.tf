terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/03-eks/03-eks-infra-pod-identity/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
