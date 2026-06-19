locals {
  main_vpc_id_sin             = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  main_vpc_public_subnet_sin  = data.terraform_remote_state.network.outputs.main_vpc_public_subnets_sin
  main_vpc_private_subnet_sin = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  main_vpc_db_subnet_sin      = data.terraform_remote_state.network.outputs.main_vpc_db_subnets_sin
  main_vpc_msk_subnet_sin     = data.terraform_remote_state.network.outputs.main_vpc_msk_subnets_sin
  main_vpc_elasticache_subnet_sin = data.terraform_remote_state.network.outputs.main_vpc_elasticache_subnets_sin

  # Shared network
  aws_admin_cidr_range_map = {
    network          = "172.23.0.0/16"
    infra            = "172.21.0.0/16"
    shared-resources = "172.22.0.0/16"
    network-dev      = "172.24.0.0/16"
  }

  aws_cidr_range_map = {
    staging  = "10.40.0.0/13"
    pre-prod = "10.56.0.0/13"
    prod     = "10.64.0.0/13"
  }

  # Use /17 for the start for the main AWS Account CIDR range
  aws_main_vpc_cidr_range = cidrsubnet(local.aws_cidr_range_map[local.env], 4, 0)

  # Use /19 for the start for the main AWS Account CIDR range
  aws_network_vpc_cidr_range          = cidrsubnet(local.aws_admin_cidr_range_map["network"], 3, 0)
  aws_network_dev_vpc_cidr_range      = cidrsubnet(local.aws_admin_cidr_range_map["network-dev"], 3, 0)
  aws_infra_vpc_cidr_range            = cidrsubnet(local.aws_admin_cidr_range_map["infra"], 3, 0)
  aws_shared_resources_vpc_cidr_range = cidrsubnet(local.aws_admin_cidr_range_map["shared-resources"], 3, 0)
  aws_staging_vpc_cidr_range          = cidrsubnet(local.aws_cidr_range_map["staging"], 4, 0)
  aws_pre_prod_vpc_cidr_range         = cidrsubnet(local.aws_cidr_range_map["pre-prod"], 4, 0)
  aws_prod_vpc_cidr_range             = cidrsubnet(local.aws_cidr_range_map["prod"], 4, 0)
  aws_risk_sb_main_vpc_cidr           = "10.48.128.0/19"

  subnet_map = {
    sin = {
      main_vpc_name            = "${local.env}-main-sin"
      aws_main_vpc_cidr        = cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0)
      aws_public_subnet_all    = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 3, 0)
      aws_db_subnet_all        = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 3, 1)
      aws_private_subnet_all   = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 2, 1)
      aws_nw_vpc_cidr          = local.aws_network_vpc_cidr_range
      aws_nw_dev_vpc_cidr      = local.aws_network_dev_vpc_cidr_range
      aws_infra_vpc_cidr       = local.aws_infra_vpc_cidr_range
      main_vpc_public_subnets  = local.main_vpc_public_subnet_sin
      main_vpc_private_subnets = local.main_vpc_private_subnet_sin
      main_vpc_db_subnets      = local.main_vpc_db_subnet_sin
      main_vpc_msk_subnets     = local.main_vpc_msk_subnet_sin
      main_vpc_elasticache_subnets = local.main_vpc_elasticache_subnet_sin
    }
  }
}
