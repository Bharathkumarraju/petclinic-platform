# Create Route Table for IGW
resource "aws_route_table" "igw" {
  vpc_id = local.subnet_map["sin"]["main_vpc_id"]

  # Route IGW to Public/Protected Subnets via Firewall Endpoint
  route {
    cidr_block      = local.public_subnets_cidr_blocks[0]
    vpc_endpoint_id = local.nfw_endpoint_id_list[0]
  }

  route {
    cidr_block      = local.public_subnets_cidr_blocks[1]
    vpc_endpoint_id = local.nfw_endpoint_id_list[1]
  }

  route {
    cidr_block      = local.public_subnets_cidr_blocks[2]
    vpc_endpoint_id = local.nfw_endpoint_id_list[2]
  }

  tags       = local.igw_route_table_tags
  depends_on = [module.network_firewall]
}

# Associate route table to IGW
resource "aws_route_table_association" "igw" {
  gateway_id     = local.subnet_map["sin"]["igw_gw_id"]
  route_table_id = aws_route_table.igw.id
}

# Create Route tables per AZ for Public Subnets 
resource "aws_route_table" "public_subnets_to_nfw" {
  count  = length(local.public_subnet_route_names)
  vpc_id = local.subnet_map["sin"]["main_vpc_id"]

  tags = {
    Name = local.public_subnet_route_names[count.index]

    purpose = "Route table for Public Subnets to route all traffic to Network Firewall"

  }

  depends_on = [module.network_firewall]
}

# Default route 0.0.0.0/0 via Firewall Endpoint per AZ
resource "aws_route" "public_to_nfw" {
  count                  = length(local.public_subnet_route_names)
  route_table_id         = data.aws_route_table.nfw_public_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.nfw_endpoint_id_list[count.index]
}

# Create route to aws-nw via Transit Gateway
data "aws_route_table" "nfw_public_route_tables" {
  count          = length(aws_route_table.public_subnets_to_nfw.*.id)
  route_table_id = aws_route_table.public_subnets_to_nfw.*.id[count.index]
}

resource "aws_route" "nfw_route_nw_public" {
  count                  = length(data.aws_route_table.nfw_public_route_tables)
  route_table_id         = data.aws_route_table.nfw_public_route_tables[count.index].id
  destination_cidr_block = local.aws_network_vpc_cidr_range
  transit_gateway_id     = local.transit_gw_id_sin
}

# Associate Public Route Tables to Public Subnets
# MANUAL STEP NEEDED FROM AWS CONSOLE: disassociate Public Subnets from default Public Route Table
resource "aws_route_table_association" "public_subnets_to_nfw" {
  count          = length(local.public_subnets_id_list)
  subnet_id      = local.public_subnets_id_list[count.index]
  route_table_id = aws_route_table.public_subnets_to_nfw[count.index].id
}
