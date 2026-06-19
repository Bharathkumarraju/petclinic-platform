# data "terraform_remote_state" "buckets" {
#   backend = "s3"
#   config = {
#     bucket = "abaxx-exch-tf-state-nonprod"
#     key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/03-bucket/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

# data "aws_region" "current" {}

# # Network information for the account the influxdb is deployed too
# data "terraform_remote_state" "workload_network" {
#   backend = "s3"
#   config = {
#     bucket = local.bucket_name
#     key    = "abaxxsingapore/abex-aws-env-${local.env}/layers/000base/06-network/layer-0/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

# # Network information for the core networking account (network/network-dev)
# data "terraform_remote_state" "core_network" {
#   backend = "s3"
#   config = {
#     bucket = local.bucket_name
#     key    = "abaxxsingapore/abex-aws-env-network-dev/layers/000base/06-network/layer-0/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }