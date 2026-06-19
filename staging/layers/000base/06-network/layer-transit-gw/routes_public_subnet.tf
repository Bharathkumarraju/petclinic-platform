data "aws_route_table" "public_route_tables" {
  count          = length(local.public_route_tables)
  route_table_id = local.public_route_tables[count.index]
}

# Route Public to Nw Dev for VPN accesibility to SFTP
resource "aws_route" "public_to_nw_dev" {
  count                  = length(data.aws_route_table.public_route_tables)
  route_table_id         = data.aws_route_table.public_route_tables[count.index].id
  destination_cidr_block = local.aws_network_dev_vpc_cidr_range
  transit_gateway_id     = local.transit_gw_id_sin
}


