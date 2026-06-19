
data "aws_route_table" "private_route_tables" {
  count          = length(local.private_route_tables)
  route_table_id = local.private_route_tables[count.index]
}

# Route Private to Nw Dev for Atlantis / Github Actions
resource "aws_route" "private_to_nw_dev" {
  count                  = length(data.aws_route_table.private_route_tables)
  route_table_id         = data.aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = local.aws_network_dev_vpc_cidr_range
  transit_gateway_id     = local.transit_gw_id_sin
}

# TODO: To be revised (cidr range should be limited to a dedicated VPC or subnet range in which the UAT/staging instance resides)
# Route Private to Shared for Swift Testing
resource "aws_route" "private_to_shared" {
  count                  = length(data.aws_route_table.private_route_tables)
  route_table_id         = data.aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = local.aws_shared_resources_vpc_cidr_range
  transit_gateway_id     = local.transit_gw_id_sin
}
