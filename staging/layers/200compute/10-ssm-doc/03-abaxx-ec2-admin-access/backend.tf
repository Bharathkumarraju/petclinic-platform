terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/10-ssm-doc/03-abaxx-ec2-admin-access/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
