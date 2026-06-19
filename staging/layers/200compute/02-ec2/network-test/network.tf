locals {
  main_vpc_id_sin             = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  main_vpc_public_subnet_sin  = data.terraform_remote_state.network.outputs.main_vpc_public_subnets_sin
  main_vpc_private_subnet_sin = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  main_vpc_db_subnet_sin      = data.terraform_remote_state.network.outputs.main_vpc_db_subnets_sin


  subnet_map = {
    sin = {
      main_vpc_name            = "${local.env}-main-sin"
      main_vpc_public_subnets  = local.main_vpc_public_subnet_sin
      main_vpc_private_subnets = local.main_vpc_private_subnet_sin
      main_vpc_db_subnets      = local.main_vpc_db_subnet_sin
    }

  }
}