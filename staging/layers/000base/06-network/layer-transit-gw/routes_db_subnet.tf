data "aws_route_table" "db_route_tables" {
  count          = length(local.db_route_tables)
  route_table_id = local.db_route_tables[count.index]
}

# Route DB to Nw Dev for VPN => Staging Databases
resource "aws_route" "db_to_nw_dev" {
  count                  = length(data.aws_route_table.db_route_tables)
  route_table_id         = data.aws_route_table.db_route_tables[count.index].id
  destination_cidr_block = local.aws_network_dev_vpc_cidr_range
  transit_gateway_id     = local.transit_gw_id_sin
}
