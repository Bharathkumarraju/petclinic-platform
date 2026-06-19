locals {
  # We will only use 3 NAT GWs for pre-prod and prod to reduce cost
  no_of_nat_gw = 1
}

resource "aws_eip" "nat_ip_sin" {
  count                = local.no_of_nat_gw
  network_border_group = local.region_map["sin"]
  tags                 = local.tags
}
