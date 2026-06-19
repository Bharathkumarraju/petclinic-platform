# Security Groups
module "vm_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.vm_sg_tags_sin
  name            = local.vm_sg_tags_sin["Name"]
  use_name_prefix = false


  ingress_with_cidr_blocks = [
    {
      # ssh
      description = "Allow SSH from aws_nw"
      # protocol    = "tcp",
      # from_port   = 22,
      # to_port     = 22,
      rule        = "ssh-tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
    },
  ]

  egress_with_cidr_blocks = [
    {
      # Mysql
      description = "Allow Mysql to RDS proxy"
      rule        = "mysql-tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    },
  ]
}

# module "rds_proxy_sg_sin" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.17.1"

#   vpc_id          = local.main_vpc_id_sin
#   tags            = local.rds_proxy_sg_tags_sin
#   name            = local.rds_proxy_sg_tags_sin["Name"]
#   use_name_prefix = false


#   ingress_with_cidr_blocks = [
#     {
#       # Mysql
#       description = "Allow Mysql to RDS proxy"
#       rule        = "mysql-tcp"
#       cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
#     },
#   ]

#   computed_ingress_with_source_security_group_id = [
#     {
#       # Mysql
#       description              = "Allow Mysql to RDS proxy"
#       rule                     = "mysql-tcp"
#       source_security_group_id = module.vm_sg_sin.security_group_id
#     },
#   ]

#   number_of_computed_ingress_with_source_security_group_id = 1

#   egress_with_cidr_blocks = [
#     {
#       # Mysql
#       description = "Allow Mysql to RDS"
#       rule        = "mysql-tcp"
#       cidr_blocks = local.subnet_map["sin"]["aws_db_subnet_all"]
#     },
#   ]
# }

# module "rds_sg_sin" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.17.1"

#   vpc_id          = local.main_vpc_id_sin
#   tags            = local.rds_sg_tags_sin
#   name            = local.rds_sg_tags_sin["Name"]
#   use_name_prefix = false


#   computed_ingress_with_source_security_group_id = [
#     {
#       # Mysql
#       description              = "Allow Mysql to RDS proxy"
#       rule                     = "mysql-tcp"
#       source_security_group_id = module.rds_proxy_sg_sin.security_group_id
#     },
#   ]

#   number_of_computed_ingress_with_source_security_group_id = 1


# }

module "ec2_teleport_db_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.ec2_teleport_db_sg_tags_sin
  name            = local.ec2_teleport_db_sg_tags_sin["Name"]
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      # ssh
      description = "Allow SSH from AWS-NW CIDR"
      rule        = "ssh-tcp"
      cidr_blocks = join(",",
        [
          local.subnet_map["sin"]["aws_main_vpc_cidr"],
          local.subnet_map["sin"]["aws_nw_vpc_cidr"],
      ])
    },
  ]
  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_ingress_with_source_security_group_id = [
    {
      description              = "Allow the VM to comm within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.ec2_teleport_db_sg_sin.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1


}

module "ec2_cronicle_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.ec2_cronicle_sg_tags_sin
  name            = local.ec2_cronicle_sg_tags_sin["Name"]
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      # ssh
      description = "Allow SSH from AWS-Staging,AWS-NW,AWS-INFRA CIDR"
      rule        = "ssh-tcp"
      cidr_blocks = join(",",
        [
          local.subnet_map["sin"]["aws_main_vpc_cidr"],
          local.subnet_map["sin"]["aws_nw_vpc_cidr"],
          local.subnet_map["sin"]["aws_infra_vpc_cidr"],
      ])
    },
    {
      # TCP 3012 - Cronicle web UI
      description = "Allow 3012 from AWS-staging private subnets"
      protocol    = "tcp"
      from_port   = 3012
      to_port     = 3012
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    },
    {
      # TCP 3012 - Cronicle web UI
      description = "Allow 3012 from AWS-NW private subnets"
      protocol    = "tcp"
      from_port   = 3012
      to_port     = 3012
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
    },
  ]
  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_ingress_with_source_security_group_id = [
    {
      description              = "Allow the VM to comm within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.ec2_cronicle_sg_sin.security_group_id
    },
    {
      description              = "Allow the EFS to comm with EC2 via NFS protocol"
      protocol                 = "tcp"
      from_port                = 2049
      to_port                  = 2049
      source_security_group_id = module.efs_cronicle_sg_sin.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

}

module "elastic_agent_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.elastic_agent_sg_tags_sin
  name            = local.elastic_agent_sg_tags_sin["Name"]
  use_name_prefix = false


  ingress_with_cidr_blocks = [
    {
      # ssh
      description = "Allow SSH from AWS-Staging,AWS-NW CIDR"
      rule        = "ssh-tcp"
      cidr_blocks = join(",",
        [
          local.subnet_map["sin"]["aws_main_vpc_cidr"],
          local.subnet_map["sin"]["aws_nw_vpc_cidr"],
      ])
    },
    {
      # TCP 8220 - Elastic Fleet Port
      description = "Allow 8220 from AWS-NW private subnets"
      protocol    = "tcp"
      from_port   = 8220
      to_port     = 8220
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
    },
    {
      # TCP 8200 - Elastic APM
      description = "Allow 8200 from AWS-Staging,AWS-NW CIDR"
      protocol    = "tcp"
      from_port   = 8200
      to_port     = 8200
      cidr_blocks = join(",",
        [
          local.subnet_map["sin"]["aws_main_vpc_cidr"],
          local.subnet_map["sin"]["aws_nw_vpc_cidr"],
      ])
    },
    {
      # TCP 9243 - Elastic Fleet
      description = "Allow 9243 from AWS-Staging CIDR"
      protocol    = "tcp"
      from_port   = 9243
      to_port     = 9243
      cidr_blocks = join(",",
        [
          local.subnet_map["sin"]["aws_main_vpc_cidr"],
      ])
    },
  ]

  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

# Security group for Elastic Cloud VPC Endpoints
module "elastic_cloud_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id = local.main_vpc_id_sin
  tags   = local.elastic_cloud_sin

  name            = local.elastic_cloud_sin["Name"]
  use_name_prefix = false


  ingress_with_cidr_blocks = [
    {
      description = "Allow 443 to access"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    },
    {
      description = "Allow 9243 to access"
      protocol    = "tcp"
      from_port   = 9243
      to_port     = 9243
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    }
  ]
  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "efs_cronicle_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.efs_cronicle_sg_tags_sin
  name            = local.efs_cronicle_sg_tags_sin["Name"]
  use_name_prefix = false

  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_ingress_with_source_security_group_id = [
    {
      description              = "Allow the EFS to comm with EC2 via NFS protocol"
      protocol                 = "tcp"
      from_port                = 2049
      to_port                  = 2049
      source_security_group_id = module.ec2_cronicle_sg_sin.security_group_id
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

}


module "interface_vpc_endpoint_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.interface_vpc_endpoint_sg_tags_sin
  name            = local.interface_vpc_endpoint_sg_tags_sin["Name"]
  use_name_prefix = false


  ingress_with_cidr_blocks = [
    {
      # https
      description = "Allow https from all subnets"
      rule        = "https-443-tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_main_vpc_cidr"]
    },
    {
      # smtp
      description = "Allow smtp from vpc"
      protocol    = "tcp",
      from_port   = 587,
      to_port     = 587,
      cidr_blocks = local.subnet_map["sin"]["aws_main_vpc_cidr"]
    },
    {
      # nfs
      description = "Allow nfs from vpc"
      protocol    = "tcp",
      from_port   = 2049,
      to_port     = 2049,
      cidr_blocks = local.subnet_map["sin"]["aws_main_vpc_cidr"]
    },

  ]
}


module "mq_internal_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.mq_internal_sin
  name            = local.mq_internal_sin["Name"]
  use_name_prefix = false


  ingress_with_cidr_blocks = [
    // STOMP - 61614
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
      description = "Allow Private Subnet CIDR to access to MQ"
    },
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_public_subnet_all"]
      description = "Allow Public Subnet CIDR to access to MQ"
    },
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow AWS-NW to access to MQ"
    },
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow AWS-NW-DEV to access to MQ"
    },
    // OpenWire - 61617
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
      description = "Allow Private Subnet CIDR to access to MQ"
    },
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_public_subnet_all"]
      description = "Allow Public Subnet CIDR to access to MQ"
    },
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow AWS-NW to access to MQ"
    },
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow AWS-NW-DEV to access to MQ"
    },

    // WSS - 61619
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
      description = "Allow Private Subnet CIDR to access to MQ"
    },
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_public_subnet_all"]
      description = "Allow Public Subnet CIDR to access to MQ"
    },
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow AWS-NW to access to MQ"
    },
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow AWS-NW-DEV to access to MQ"
    },
    // AMQP - 5671
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
      description = "Allow Private Subnet CIDR to access to MQ"
    },
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_public_subnet_all"]
      description = "Allow Public Subnet CIDR to access to MQ"
    },
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow AWS-NW to access to MQ"
    },
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow AWS-NW-DEV to access to MQ"
    },
    // MQTT - 8883
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
      description = "Allow Private Subnet CIDR to access to MQ"
    },
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_public_subnet_all"]
      description = "Allow Public Subnet CIDR to access to MQ"
    },
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow AWS-NW to access to MQ"
    },
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow AWS-NW-DEV to access to MQ"
    },
    // ActiveMQ Web Console - 8162
    {
      from_port   = 8162
      to_port     = 8162
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
      description = "Allow Private Subnet CIDR to access to MQ"
    },
    {
      from_port   = 8162
      to_port     = 8162
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow AWS-NW to access to MQ"
    },
    {
      from_port   = 8162
      to_port     = 8162
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow AWS-NW-DEV to access to MQ"
    },
  ]
  egress_with_cidr_blocks = [
    {
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_egress_with_source_security_group_id = [
    {
      description              = "Allow within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.mq_internal_sg_sin.security_group_id
    }
  ]

}

module "mq_internal_alb_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.mq_internal_alb_sin
  name            = local.mq_internal_alb_sin["Name"]
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      description = "Allow https from NW CIDR"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_infra_vpc_cidr"]
    },
    {
      description = "Allow https from NW CIDR"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
    },
    {
      description = "Allow https from NW CIDR"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_egress_with_source_security_group_id = [
    {
      description              = "Allow within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.mq_internal_alb_sg_sin.security_group_id
    }
  ]
}

module "mq_internal_nlb_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.mq_internal_nlb_sin
  name            = local.mq_internal_nlb_sin["Name"]
  use_name_prefix = false
  ingress_with_cidr_blocks = [
    // STOMP - 61614
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow nw-dev to access to MQ"
    },
    // OpenWire - 61617
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow nw-dev to access to MQ"
    },
    // WSS - 61619
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    // AMQP - 5671
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    // MQTT - 8883
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      description = "Allow External services to access to MQ"
    },
  ]
  egress_with_cidr_blocks = [
    {
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_egress_with_source_security_group_id = [
    {
      description              = "Allow within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.mq_internal_nlb_sg_sin.security_group_id
    }
  ]
}


module "mq_external_nlb_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.mq_external_alb_sin
  name            = local.mq_external_alb_sin["Name"]
  use_name_prefix = false

  # ---------------------------------------------------------
  # 1. External Access (Optimized)
  # ---------------------------------------------------------
  ingress_with_prefix_list_ids = [
    # Combined Range: STOMP (61614) + OpenWire (61617) + WSS (61619)
    {
      from_port       = 61614
      to_port         = 61619
      protocol        = "tcp"
      description     = "Allow STOMP/OpenWire/WSS via Cloudflare"
      prefix_list_ids = aws_ec2_managed_prefix_list.cloudflare.id
    },
    # AMQP - 5671
    {
      from_port       = 5671
      to_port         = 5671
      protocol        = "tcp"
      description     = "Allow AMQP via Cloudflare"
      prefix_list_ids = aws_ec2_managed_prefix_list.cloudflare.id
    },
    # MQTT - 8883
    {
      from_port       = 8883
      to_port         = 8883
      protocol        = "tcp"
      description     = "Allow MQTT via Cloudflare"
      prefix_list_ids = aws_ec2_managed_prefix_list.cloudflare.id
    }
  ]

  # ---------------------------------------------------------
  # 2. Internal Access
  # ---------------------------------------------------------
  ingress_with_cidr_blocks = [
    # STOMP - 61614
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      description = "Allow STOMP from Internal VPCs"
      cidr_blocks = join(",", [
        local.subnet_map["sin"]["aws_nw_vpc_cidr"],
        local.subnet_map["sin"]["aws_main_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      ])
    },
    # OpenWire - 61617
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      description = "Allow OpenWire from Internal VPCs"
      cidr_blocks = join(",", [
        local.subnet_map["sin"]["aws_nw_vpc_cidr"],
        local.subnet_map["sin"]["aws_main_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      ])
    },
    # WSS - 61619
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      description = "Allow WSS from Internal VPCs"
      cidr_blocks = join(",", [
        local.subnet_map["sin"]["aws_nw_vpc_cidr"],
        local.subnet_map["sin"]["aws_main_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      ])
    },
    # AMQP - 5671
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      description = "Allow AMQP from Internal VPCs"
      cidr_blocks = join(",", [
        local.subnet_map["sin"]["aws_nw_vpc_cidr"],
        local.subnet_map["sin"]["aws_main_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      ])
    },
    # MQTT - 8883
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      description = "Allow MQTT from Internal VPCs"
      cidr_blocks = join(",", [
        local.subnet_map["sin"]["aws_nw_vpc_cidr"],
        local.subnet_map["sin"]["aws_main_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"]
      ])
    }
  ]

  egress_with_cidr_blocks = [
    {
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  computed_egress_with_source_security_group_id = [
    {
      description              = "Allow within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.mq_external_nlb_sg_sin.security_group_id
    }
  ]
}

#Cluster Security Group
module "eks_cluster_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.eks_cluster_sg_tags_sin
  name            = local.eks_cluster_sg_tags_sin["Name"]
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      description = "Allow https from NW CIDR"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_infra_vpc_cidr"]
    },
    {
      description = "Allow https from NW CIDR"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
    },
    {
      # Allow from aws_nw
      description = "Allow access from control plane to webhook port of AWS load balancer controller"
      protocol    = "tcp"
      from_port   = 9443
      to_port     = 9443
      cidr_blocks = local.subnet_map["sin"]["aws_nw_vpc_cidr"]
    },
    {
      # Allow from aws_nw
      description = "Allow access from control plane to webhook port of AWS load balancer controller"
      protocol    = "tcp"
      from_port   = 9443
      to_port     = 9443
      cidr_blocks = local.subnet_map["sin"]["aws_infra_vpc_cidr"]
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_egress_with_source_security_group_id = [
    {
      description              = "Allow within the security group"
      protocol                 = "all"
      from_port                = 0
      to_port                  = 0
      source_security_group_id = module.eks_cluster_sg_sin.security_group_id
    }
  ]
}



resource "aws_ec2_managed_prefix_list" "cloudflare" {
  name           = "cloudflare-spectrum-ipv4"
  address_family = "IPv4"
  max_entries    = 32

  dynamic "entry" {
    for_each = local.cloudflare_ipv4
    content {
      cidr        = entry.value
      description = "Cloudflare"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "sftp_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id          = local.main_vpc_id_sin
  tags            = local.sftp_sg_tags_sin
  name            = local.sftp_sg_tags_sin["Name"]
  use_name_prefix = false

  ingress_with_cidr_blocks = local.sftp_internal_ssh_ingress

  ingress_with_prefix_list_ids = [
    {
      description     = "SFTP/SSH via Cloudflare"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      prefix_list_ids = aws_ec2_managed_prefix_list.cloudflare.id
    }
  ]

  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
# Security group for Exberry VPC Endpoints
module "exberry_internal_sg_sin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  vpc_id = local.main_vpc_id_sin
  tags   = local.exberry_internal_sin
  # tags = merge(local.exberry_internal_sin, local.default_tags)

  name            = local.exberry_internal_sin["Name"]
  use_name_prefix = false


  ingress_with_cidr_blocks = [
    {
      description = "Allow 443 to access"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    },
    {
      description = "Allow 11080 to access"
      protocol    = "tcp"
      from_port   = 11080
      to_port     = 11080
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    }
  ]
  egress_with_cidr_blocks = [
    {
      # Ephemeral
      description = "Allow all outgoing traffic"
      protocol    = "all"
      from_port   = 443
      to_port     = 443
      cidr_blocks = local.subnet_map["sin"]["aws_private_subnet_all"]
    }
  ]
}

# module "eks_alb_external_sg_sin" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.17.1"

#   vpc_id          = local.main_vpc_id_sin
#   tags            = local.eks_alb_external_tags_sin
#   name            = local.eks_alb_external_tags_sin["Name"]
#   use_name_prefix = false

#   ingress_with_cidr_blocks = [
#     {
#       # http
#       description = "Allow http from external"
#       rule        = "http-80-tcp"
#       cidr_blocks = "0.0.0.0/0"
#     },
#     {
#       # https
#       description = "Allow https from external"
#       rule        = "https-443-tcp"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]
#   egress_with_cidr_blocks = [
#     {
#       # Ephemeral
#       description = "Allow all outgoing traffic"
#       protocol    = "all"
#       from_port   = 0
#       to_port     = 0
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]
#   computed_ingress_with_source_security_group_id = [
#     {
#       description              = "Allow the VM to comm within the security group"
#       protocol                 = "all"
#       from_port                = 0
#       to_port                  = 0
#       source_security_group_id = module.eks_alb_external_sg_sin.security_group_id
#     },
#   ]

#   number_of_computed_ingress_with_source_security_group_id = 1


# }
