locals {
  main_vpc_id_sin      = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  private_route_tables = data.terraform_remote_state.network.outputs.main_vpc_private_route_table_ids_sin
  public_route_tables  = data.terraform_remote_state.network.outputs.main_vpc_public_route_table_ids_sin
  db_route_tables      = data.terraform_remote_state.network.outputs.main_vpc_db_route_table_ids_sin
  #  transit_gw_id_sin    = data.terraform_remote_state.transit-gw.outputs.transit_gw_ec2_transit_gateway_arn.ec2_transit_gateway_id

  transit_gw_id_sin = data.terraform_remote_state.transit-gw-dev.outputs.transit_gateway_id

  # Shared network
  aws_admin_cidr_range_map = {
    network-dev      = "172.24.0.0/16"
    infra            = "172.21.0.0/16"
    shared-resources = "172.22.0.0/16"
  }

  # Overall IP Address CIDR reserved per environment catered for future
  aws_cidr_range_map = {
    staging = "10.40.0.0/13"
  }

  # Use /19 for the start for the main AWS Account CIDR range
  aws_network_dev_vpc_cidr_range = cidrsubnet(local.aws_admin_cidr_range_map["network-dev"], 3, 0)

  aws_shared_resources_vpc_cidr_range = cidrsubnet(local.aws_admin_cidr_range_map["shared-resources"], 3, 0)
  aws_staging_vpc_cidr_range          = cidrsubnet(local.aws_cidr_range_map["staging"], 4, 0)
  aws_risk_sb_main_vpc_cidr           = "10.48.128.0/19"
}

