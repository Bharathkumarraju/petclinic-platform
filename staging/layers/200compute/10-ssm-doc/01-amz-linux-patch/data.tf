data "terraform_remote_state" "cloud-elastic-agent-amz-linux" {
  backend = "s3"

  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/200compute/02-ec2/04-cloud-elastic-agent-amz-linux/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
