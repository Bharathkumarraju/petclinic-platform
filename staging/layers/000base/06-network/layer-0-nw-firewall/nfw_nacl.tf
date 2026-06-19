locals {

  # Define NACL rules for Firewall Subnet
  firewall_nacl_inbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 50,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  firewall_nacl_outbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 50,
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# Create NACL for Firewall Subnet 
resource "aws_network_acl" "firewall_nacl_sin" {
  vpc_id = local.main_vpc_id_sin
  tags   = local.firewall_nacl_tags_sin

  dynamic "ingress" {
    for_each = local.firewall_nacl_inbound_rules_sin

    content {
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      rule_no    = ingress.value.rule_num
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      cidr_block = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.firewall_nacl_outbound_rules_sin

    content {
      protocol   = egress.value.protocol
      action     = egress.value.action
      rule_no    = egress.value.rule_num
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
      cidr_block = egress.value.cidr_blocks
    }
  }
}

# Tie Firewall NACL to Subnet
resource "aws_network_acl_association" "firewall_nacl_assoc_sin" {
  for_each       = toset(local.subnet_map["sin"]["main_vpc_firewall_subnets"])
  subnet_id      = each.value
  network_acl_id = aws_network_acl.firewall_nacl_sin.id
}
