data "terraform_remote_state" "kms_msk" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/msk/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
