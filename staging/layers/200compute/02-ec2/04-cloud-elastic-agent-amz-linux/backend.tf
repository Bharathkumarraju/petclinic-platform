terraform {
  backend "s3" {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/200compute/02-ec2/04-cloud-elastic-agent-amz-linux/terraform.tfstate"
    region = "ap-southeast-1"

  }
}
