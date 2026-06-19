
###### Reading TF state for secrets KMS Keys #######


data "terraform_remote_state" "kms-s3-logs-sin" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/01-kms/s3_bucket/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# data "terraform_remote_state" "elastic_agent" {
#   backend = "s3"
#   config = {
#     bucket = "abaxx-exch-tf-state-nonprod"
#     key    = "abaxxsingapore/abex-cross-elastic-cloud/200stacks/nonprod/abex-nonprod/agents/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }
