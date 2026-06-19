data "terraform_remote_state" "buckets" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/03-bucket/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
