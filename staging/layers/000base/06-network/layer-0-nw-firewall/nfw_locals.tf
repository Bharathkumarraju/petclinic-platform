locals {
  # Route tables
  firewall_route_tables = data.terraform_remote_state.network.outputs.main_vpc_firewall_route_table_ids_sin
  public_route_tables   = data.terraform_remote_state.network.outputs.main_vpc_public_route_table_ids_sin

  # IGW ID
  igw_gw_id = data.terraform_remote_state.network.outputs.main_vpc_igw_id_sin

  # Pull subnet details
  main_vpc_id_sin                         = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  main_vpc_public_subnet_sin              = data.terraform_remote_state.network.outputs.main_vpc_public_subnets_sin
  main_vpc_public_subnets_cidr_blocks_sin = data.terraform_remote_state.network.outputs.main_vpc_public_subnets_cidr_blocks_sin
  main_vpc_private_subnet_sin             = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  main_vpc_db_subnet_sin                  = data.terraform_remote_state.network.outputs.main_vpc_db_subnets_sin
  main_vpc_firewall_subnet_sin            = data.terraform_remote_state.network.outputs.main_vpc_firewall_subnets_sin

  # NFW Endpoint ID List
  #nfw_endpoint_id_list = [module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1b, module.network_firewall.endpoint_id_az.ap-southeast-1c]
  nfw_endpoint_id_list = [module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1a]

  # Public Route Table Names List
  public_subnet_route_names = ["${local.env}-main-sin-public-ap-southeast-1a", "${local.env}-main-sin-public-ap-southeast-1b", "${local.env}-main-sin-public-ap-southeast-1c"]

  # Public Subnet CIDR List
  public_subnets_cidr_blocks = local.main_vpc_public_subnets_cidr_blocks_sin

  # Public Subnet ID List 
  public_subnets_id_list = local.main_vpc_public_subnet_sin

  # Overall IP Address CIDR reserved per environment catered for future
  aws_cidr_range_map = {
    staging  = "10.40.0.0/13"
    pre-prod = "10.56.0.0/13"
    prod     = "10.64.0.0/13"
  }

  # Use /17 for the start for the main AWS Account CIDR range
  aws_main_vpc_cidr_range = cidrsubnet(local.aws_cidr_range_map[local.env], 4, 0)

  # Use /19 for the start for the main AWS Account CIDR range
  aws_staging_vpc_cidr_range  = cidrsubnet(local.aws_cidr_range_map["staging"], 4, 0)
  aws_pre_prod_vpc_cidr_range = cidrsubnet(local.aws_cidr_range_map["pre-prod"], 4, 0)
  aws_prod_vpc_cidr_range     = cidrsubnet(local.aws_cidr_range_map["prod"], 4, 0)
  aws_risk_sb_main_vpc_cidr   = "10.48.128.0/19"

  subnet_map = {

    sin = {
      main_vpc_id       = local.main_vpc_id_sin
      igw_gw_id         = local.igw_gw_id
      main_vpc_name     = "${local.env}-main-sin"
      aws_main_vpc_cidr = cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0)
      aws_azs           = ["${local.region_map["sin"]}a", "${local.region_map["sin"]}b", "${local.region_map["sin"]}c"]

      # Entire subnet range
      aws_public_subnet_all = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 3, 0)

      # List of 3 subnets
      main_vpc_public_subnets_cidr = local.main_vpc_public_subnets_cidr_blocks_sin
      aws_db_subnet_all            = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 3, 1)
      aws_private_subnet_all       = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 2, 1)
      aws_firewall_subnet_all      = cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 6, 32)

      # Subnet ids
      main_vpc_public_subnets   = local.main_vpc_public_subnet_sin
      main_vpc_private_subnets  = local.main_vpc_private_subnet_sin
      main_vpc_db_subnets       = local.main_vpc_db_subnet_sin
      main_vpc_firewall_subnets = local.main_vpc_firewall_subnet_sin
      firewall_route_table      = local.firewall_route_tables
      public_route_table        = local.public_route_tables
      firewall_name             = "${local.env}-firewall-sin"
    },
  }

  # Route to NW via Transit Gateway
  aws_admin_cidr_range_map = {
    network = "172.24.0.0/16"
  }
  aws_network_vpc_cidr_range = cidrsubnet(local.aws_admin_cidr_range_map["network"], 3, 0)
  #transit_gw_id_sin          = data.terraform_remote_state.transit-gw.outputs.transit_gw_ec2_transit_gateway_id
  transit_gw_id_sin = data.terraform_remote_state.transit-gw-dev.outputs.transit_gateway_id
  network_fw_bucket = data.terraform_remote_state.bucket.outputs.network_fw_bucket_sin_name
}
