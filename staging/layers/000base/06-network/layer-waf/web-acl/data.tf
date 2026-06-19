data "terraform_remote_state" "ip-set" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-waf/ip-set/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
