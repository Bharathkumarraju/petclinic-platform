#Tie public_nacl to public subnet
resource "aws_network_acl_association" "public_nacl_assoc_sin" {
  for_each       = toset(local.subnet_map["sin"]["main_vpc_public_subnets"])
  subnet_id      = each.value
  network_acl_id = aws_network_acl.public_nacl_sin.id
}

#Tie private_nacl to private subnet
resource "aws_network_acl_association" "private_nacl_assoc_sin" {
  for_each       = toset(local.subnet_map["sin"]["main_vpc_private_subnets"])
  subnet_id      = each.value
  network_acl_id = aws_network_acl.private_nacl_sin.id
}

#Tie db_nacl to db subnet
resource "aws_network_acl_association" "db_nacl_assoc_sin" {
  for_each       = toset(local.subnet_map["sin"]["main_vpc_db_subnets"])
  subnet_id      = each.value
  network_acl_id = aws_network_acl.db_nacl_sin.id
}

#Tie msk_nacl to msk subnet
resource "aws_network_acl_association" "msk_nacl_assoc_sin" {
  for_each       = toset(local.subnet_map["sin"]["main_vpc_msk_subnets"])
  subnet_id      = each.value
  network_acl_id = aws_network_acl.msk_nacl_sin.id
}
  
#Tie elasticache_nacl to elasticache subnet
resource "aws_network_acl_association" "elasticache_nacl_assoc_sin" {
  for_each       = toset(local.subnet_map["sin"]["main_vpc_elasticache_subnets"])
  subnet_id      = each.value
  network_acl_id = aws_network_acl.elasticache_nacl_sin.id
}

locals {

  #Define Public NACL rules
  public_nacl_inbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  public_nacl_outbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    },
  ]

}

# Manage all Egress and Ingress to public
resource "aws_network_acl" "public_nacl_sin" {
  vpc_id = local.main_vpc_id_sin
  tags   = local.public_nacl_tags_sin

  # allow ingress to public
  dynamic "ingress" {
    for_each = local.public_nacl_inbound_rules_sin

    content {
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      rule_no    = ingress.value.rule_num
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      cidr_block = ingress.value.cidr_blocks
    }
  }
  # allow egress
  dynamic "egress" {
    for_each = local.public_nacl_outbound_rules_sin

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

locals {

  #Define Private NACL rules
  private_nacl_inbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  private_nacl_outbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

resource "aws_network_acl" "private_nacl_sin" {
  vpc_id = local.main_vpc_id_sin
  tags   = local.private_nacl_tags_sin

  # allow ingress to private
  dynamic "ingress" {
    for_each = local.private_nacl_inbound_rules_sin

    content {
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      rule_no    = ingress.value.rule_num
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      cidr_block = ingress.value.cidr_blocks
    }
  }
  # allow egress
  dynamic "egress" {
    for_each = local.private_nacl_outbound_rules_sin

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

locals {

  #Define DB NACL rules
  db_nacl_inbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  db_nacl_outbound_rules_sin = [
    {
      # Allow All
      protocol    = "all",
      action      = "allow",
      from_port   = 0,
      to_port     = 0,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

resource "aws_network_acl" "db_nacl_sin" {
  vpc_id = local.main_vpc_id_sin
  tags   = local.db_nacl_tags_sin

  # allow ingress to db
  dynamic "ingress" {
    for_each = local.db_nacl_inbound_rules_sin

    content {
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      rule_no    = ingress.value.rule_num
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      cidr_block = ingress.value.cidr_blocks
    }
  }
  # allow egress
  dynamic "egress" {
    for_each = local.db_nacl_outbound_rules_sin

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

locals {

  #Define msk NACL rules
  msk_nacl_inbound_rules_sin = [
    {
      # Allow 2181
      protocol    = "tcp",
      action      = "allow",
      from_port   = 2181,
      to_port     = 2181,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    },
    {
      # Allow 2182
      protocol    = "tcp",
      action      = "allow",
      from_port   = 2182,
      to_port     = 2182,
      rule_num    = 200,
      cidr_blocks = "0.0.0.0/0"
    },
    {
      # Allow 9094
      protocol    = "tcp",
      action      = "allow",
      from_port   = 9094,
      to_port     = 9094,
      rule_num    = 300,
      cidr_blocks = "0.0.0.0/0"
    },
    {
      # Allow 9098
      protocol    = "tcp",
      action      = "allow",
      from_port   = 9098,
      to_port     = 9098,
      rule_num    = 400,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  msk_nacl_outbound_rules_sin = [
    {
      # Allow Ephemeral Ports
      protocol    = "tcp",
      action      = "allow",
      from_port   = 1024,
      to_port     = 65535, 
      rule_num    = 500,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

resource "aws_network_acl" "msk_nacl_sin" {
  vpc_id = local.main_vpc_id_sin
  tags   = local.msk_nacl_tags_sin

  # allow ingress to msk
  dynamic "ingress" {
    for_each = local.msk_nacl_inbound_rules_sin

    content {
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      rule_no    = ingress.value.rule_num
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      cidr_block = ingress.value.cidr_blocks
    }
  }
  # allow egress
  dynamic "egress" {
    for_each = local.msk_nacl_outbound_rules_sin

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

locals {

  #Define elasticache NACL rules
  elasticache_nacl_inbound_rules_sin = [
    {
      # Allow 6379
      protocol    = "tcp",
      action      = "allow",
      from_port   = 6379,
      to_port     = 6379,
      rule_num    = 100,
      cidr_blocks = "0.0.0.0/0"
    },
    {
      # Allow 11211
      protocol    = "tcp",
      action      = "allow",
      from_port   = 11211,
      to_port     = 11211,
      rule_num    = 200,
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  elasticache_nacl_outbound_rules_sin = [
    {
      # Allow Ephemeral Ports
      protocol    = "tcp",
      action      = "allow",
      from_port   = 1024,
      to_port     = 65535, 
      rule_num    = 300,
      cidr_blocks = "0.0.0.0/0"
    } 
  ]

}

resource "aws_network_acl" "elasticache_nacl_sin" {
  vpc_id = local.main_vpc_id_sin
  tags   = local.elasticache_nacl_tags_sin

  # allow ingress to elasticache
  dynamic "ingress" {
    for_each = local.elasticache_nacl_inbound_rules_sin

    content {
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      rule_no    = ingress.value.rule_num
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
      cidr_block = ingress.value.cidr_blocks
    }
  }
  # allow egress
  dynamic "egress" {
    for_each = local.elasticache_nacl_outbound_rules_sin

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