locals {
  staging_vpc_id             = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  staging_private_subnet_ids = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
}