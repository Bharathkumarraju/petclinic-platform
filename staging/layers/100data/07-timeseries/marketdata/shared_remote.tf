data "terraform_remote_state" "kms" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/cloudwatch_logs/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
