module "main_vpc_sin" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = local.subnet_map["sin"]["main_vpc_name"]
  cidr = local.subnet_map["sin"]["aws_main_vpc_cidr"]
  azs  = local.subnet_map["sin"]["aws_azs"]

  #Create Public Subnets outside this module to allow custom route tables
  #public_subnets   = local.subnet_map["sin"]["aws_public_subnets"]
  database_subnets = local.subnet_map["sin"]["aws_db_subnets"]
  private_subnets  = local.subnet_map["sin"]["aws_private_subnets"]

  #Set to false to allow network gateway routes to be added
  create_igw                         = false
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  database_inbound_acl_rules         = local.default_db_acl_ingress
  #database_outbound_acl_rules                    = {}

  # Create NAT Gateway outside of this module
  enable_nat_gateway = false
  # These 2 settings are on opposite ends. If 1 is true, the other is false. 
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_flow_log        = true
  #flow_log_destination_type                       = "cloud-watch-logs"
  flow_log_destination_type = "s3"
  #flow_log_cloudwatch_log_group_name_prefix = ""
  flow_log_max_aggregation_interval = 600
  # flow_log_cloudwatch_log_group_retention_in_days = 90
  flow_log_log_format = local.vpc_flow_log_format

  # flow_log_destination_arn                 = local.subnet_map["sin"]["main_vpc_flow_log_arn"]
  flow_log_destination_arn = local.vpc_flow_log_bucket_arn
  #flow_log_cloudwatch_iam_role_arn = local.subnet_map["sin"]["main_vpc_flow_log_role_arn"]
  #  flow_log_cloudwatch_log_group_kms_key_id = local.subnet_map["sin"]["main_vpc_flow_log_kms_key_arn"]
  #create_flow_log_cloudwatch_iam_role  = false
  #create_flow_log_cloudwatch_log_group = false
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []
  manage_default_network_acl     = true
  default_network_acl_ingress    = local.default_network_acl_ingress

  #List of perm EIPs to be assigned
  external_nat_ip_ids = local.subnet_map["sin"]["main_eip_allocations_ids"]
  reuse_nat_ips       = true

  #Enable DHCP    
  enable_dhcp_options = true
  #dhcp_options_domain_name                = "service.consul"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
  tags                             = local.tags
  public_subnet_tags               = local.public_subnet_tags
  private_subnet_tags              = local.private_subnet_tags

}

module "s3_vpc_endpoints_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/vpc-endpoint-gateway"

  main_vpc_id = module.main_vpc_sin.vpc_id
  main_vpc_route_tables = concat(
    module.main_vpc_sin.private_route_table_ids,
    module.main_vpc_sin.database_route_table_ids
  )
  service_name          = local.s3_service_map["sin"]
  service_endpoint_tags = local.vpc_s3_endpoint_tags
}

module "dynamodb_vpc_endpoints_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/vpc-endpoint-gateway"

  main_vpc_id           = module.main_vpc_sin.vpc_id
  main_vpc_route_tables = module.main_vpc_sin.private_route_table_ids
  #  db_vpc_id               = module.db_vpc.vpc_id
  #  db_vpc_route_tables     = module.db_vpc.private_route_table_ids
  service_name          = local.dynamodb_service_map["sin"]
  service_endpoint_tags = local.vpc_dynamodb_endpoint_tags
}

# Create the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = module.main_vpc_sin.vpc_id
  tags   = local.igw_tags
}

# Create Firewall Subnets
resource "aws_subnet" "firewall_subnet" {
  count             = length(local.subnet_map["sin"]["aws_firewall_subnet_names"])
  vpc_id            = module.main_vpc_sin.vpc_id
  availability_zone = local.subnet_map["sin"]["aws_azs"][count.index]
  cidr_block        = local.subnet_map["sin"]["aws_firewall_subnets"][count.index]
  tags = {
    Name = local.subnet_map["sin"]["aws_firewall_subnet_names"][count.index]

    Purpose = "Firewall Ext Subnets"
  }
}

# Create Route Table for Firewall Subnets
resource "aws_route_table" "firewall_route_table" {
  vpc_id = module.main_vpc_sin.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = local.subnet_map["sin"]["aws_firewall_route_table_name"]
  }
}

# Route Table Association with Firewall Subnets
resource "aws_route_table_association" "firewall_route_table_association" {
  count          = length(local.subnet_map["sin"]["aws_firewall_subnet_names"])
  subnet_id      = element(aws_subnet.firewall_subnet.*.id, count.index)
  route_table_id = aws_route_table.firewall_route_table.id
}

# Create Public Subnet outside of the VPC module to allow custom route tables for Network Firewall
resource "aws_subnet" "public_subnet" {
  count                   = length(local.subnet_map["sin"]["aws_public_subnet_names"])
  vpc_id                  = module.main_vpc_sin.vpc_id
  availability_zone       = local.subnet_map["sin"]["aws_azs"][count.index]
  cidr_block              = local.subnet_map["sin"]["aws_public_subnets"][count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = local.subnet_map["sin"]["aws_public_subnet_names"][count.index]


    purpose                  = "Main Network"
    "kubernetes.io/role/elb" = 1
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = element(local.subnet_map["sin"]["main_eip_allocations_ids"], 0)
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = local.nat_gateway_tags
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = module.main_vpc_sin.private_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id

  timeouts {
    create = "5m"
  }
}

# Create MSK Subnets
resource "aws_subnet" "msk_subnet" {
  count             = length(local.subnet_map["sin"]["aws_msk_subnet_names"])
  vpc_id            = module.main_vpc_sin.vpc_id
  availability_zone = local.subnet_map["sin"]["aws_azs"][count.index]
  cidr_block        = local.subnet_map["sin"]["aws_msk_subnets"][count.index]
  tags = {
    Name = local.subnet_map["sin"]["aws_msk_subnet_names"][count.index]

    Purpose = "AWS MSK Subnets"
  }
}

# Create Route Table for MSK Subnets
resource "aws_route_table" "msk_route_table" {
  vpc_id = module.main_vpc_sin.vpc_id

  tags = {
    Name = local.subnet_map["sin"]["aws_msk_route_table_name"]
  }
}

# Route Table Association with MSK Subnets
resource "aws_route_table_association" "msk_route_table_association" {
  count          = length(local.subnet_map["sin"]["aws_msk_subnet_names"])
  subnet_id      = element(aws_subnet.msk_subnet.*.id, count.index)
  route_table_id = aws_route_table.msk_route_table.id
}

resource "aws_route" "staging_msk_to_nw_dev" {
  route_table_id         = aws_route_table.msk_route_table.id
  destination_cidr_block = "172.24.0.0/21"
  transit_gateway_id     = data.terraform_remote_state.transit-gw-dev.outputs.transit_gateway_id
}

# Create Elasticache Subnets
resource "aws_subnet" "elasticache_subnet" {
  count             = length(local.subnet_map["sin"]["aws_elasticache_subnet_names"])
  vpc_id            = module.main_vpc_sin.vpc_id
  availability_zone = local.subnet_map["sin"]["aws_azs"][count.index]
  cidr_block        = local.subnet_map["sin"]["aws_elasticache_subnets"][count.index]
  tags = {
    Name = local.subnet_map["sin"]["aws_elasticache_subnet_names"][count.index]

    Purpose = "AWS ElastiCache Subnets"
  }
}

# Create Route Table for ElastiCache Subnets
resource "aws_route_table" "elasticache_route_table" {
  vpc_id = module.main_vpc_sin.vpc_id

  tags = {
    Name = local.subnet_map["sin"]["aws_elasticache_route_table_name"]
  }
}

# Route Table Association with ElastiCache Subnets
resource "aws_route_table_association" "elasticache_route_table_association" {
  count          = length(local.subnet_map["sin"]["aws_elasticache_subnet_names"])
  subnet_id      = element(aws_subnet.elasticache_subnet.*.id, count.index)
  route_table_id = aws_route_table.elasticache_route_table.id
}

# Create additional routes for Elasticache subnets to route to NW_DEV
resource "aws_route" "staging_elasticache_to_nw_dev" {
  route_table_id         = aws_route_table.elasticache_route_table.id
  destination_cidr_block = "172.24.0.0/21"
  transit_gateway_id     = data.terraform_remote_state.transit-gw-dev.outputs.transit_gateway_id
}

################################# 
# Default Security Groups
#################################
resource "aws_default_security_group" "default_security_group_vir" {
  provider = aws.vir
  vpc_id   = "vpc-01b294a85824abcea"
  ingress  = []
  egress   = []
}
