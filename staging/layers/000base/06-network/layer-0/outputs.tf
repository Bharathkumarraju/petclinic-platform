output "main_vpc_id_sin" {
  description = "The ID of the VPC"
  value       = module.main_vpc_sin.vpc_id
}

output "main_vpc_arn_sin" {
  description = "The ARN of the VPC"
  value       = module.main_vpc_sin.vpc_arn
}

output "main_vpc_cidr_block_sin" {
  description = "The CIDR block of the VPC"
  value       = module.main_vpc_sin.vpc_cidr_block
}

output "main_vpc_enable_dns_support_sin" {
  description = "Whether or not the VPC has DNS support"
  value       = module.main_vpc_sin.vpc_enable_dns_support
}

output "main_vpc_enable_dns_hostnames_sin" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = module.main_vpc_sin.vpc_enable_dns_hostnames
}

output "main_vpc_main_route_table_id_sin" {
  description = "The ID of the main route table associated with this VPC"
  value       = module.main_vpc_sin.vpc_main_route_table_id
}

output "main_vpc_owner_id_sin" {
  description = "The ID of the AWS account that owns the VPC"
  value       = module.main_vpc_sin.vpc_owner_id
}

output "main_vpc_private_subnets_sin" {
  description = "List of IDs of private subnets"
  value       = module.main_vpc_sin.private_subnets
}

output "main_vpc_private_subnet_arns_sin" {
  description = "List of ARNs of private subnets"
  value       = module.main_vpc_sin.private_subnet_arns
}

output "main_vpc_private_subnets_cidr_blocks_sin" {
  description = "List of cidr_blocks of private subnets"
  value       = module.main_vpc_sin.private_subnets_cidr_blocks
}

output "main_vpc_private_route_table_ids_sin" {
  description = "List of IDs of private route tables"
  value       = module.main_vpc_sin.private_route_table_ids
}

output "main_vpc_private_route_table_association_ids_sin" {
  description = "List of IDs of the private route table association"
  value       = module.main_vpc_sin.private_route_table_association_ids
}

output "main_vpc_private_network_acl_id_sin" {
  description = "ID of the private network ACL"
  value       = module.main_vpc_sin.private_network_acl_id
}

output "main_vpc_private_network_acl_arn_sin" {
  description = "ARN of the private network ACL"
  value       = module.main_vpc_sin.private_network_acl_arn
}

output "main_vpc_private_main_vpc_nat_gateway_route_ids_sin" {
  description = "List of IDs of the private nat gateway route"
  value       = aws_route.private_nat_gateway.id
}

output "main_vpc_db_subnets_sin" {
  description = "List of IDs of db subnets"
  value       = module.main_vpc_sin.database_subnets
}

output "main_vpc_db_subnet_arns_sin" {
  description = "List of ARNs of db subnets"
  value       = module.main_vpc_sin.database_subnet_arns
}

output "main_vpc_db_subnets_cidr_blocks_sin" {
  description = "List of cidr_blocks of db subnets"
  value       = module.main_vpc_sin.database_subnets_cidr_blocks
}

output "main_vpc_db_route_table_ids_sin" {
  description = "List of IDs of db route tables"
  value       = module.main_vpc_sin.database_route_table_ids
}

output "main_vpc_db_route_table_association_ids_sin" {
  description = "List of IDs of the db route table association"
  value       = module.main_vpc_sin.database_route_table_association_ids
}

output "main_vpc_db_subnet_group_sin" {
  description = "ID of db subnet group"
  value       = module.main_vpc_sin.database_subnet_group
}

output "main_vpc_db_subnet_group_name_sin" {
  description = "Name of db subnet group"
  value       = module.main_vpc_sin.database_subnet_group_name
}

output "main_vpc_db_network_acl_id_sin" {
  description = "ID of the db network ACL"
  value       = module.main_vpc_sin.database_network_acl_id
}

output "main_vpc_db_network_acl_arn_sin" {
  description = "ARN of the db network ACL"
  value       = module.main_vpc_sin.database_network_acl_arn
}

# output "main_vpc_db_prefix_sin" {
#   description = "Prefix list for db subnets"
#   value       = aws_ec2_managed_prefix_list.main_db_prefix
# }

# output "main_vpc_db_prefix_list_entry_sin" {
#   description = "Prefix list entries for db subnets"
#   value       = aws_ec2_managed_prefix_list_entry.main_db_prefix_entry
# }

output "main_vpc_nat_ids_sin" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = module.main_vpc_sin.nat_ids
}

output "main_vpc_nat_public_ips_sin" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.main_vpc_sin.nat_public_ips
}

output "main_vpc_natgw_ids_sin" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.natgw.*.id
}

output "main_vpc_dhcp_options_id_sin" {
  description = "The ID of the DHCP options"
  value       = module.main_vpc_sin.dhcp_options_id
}

output "main_vpc_public_subnets_sin" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnet.*.id
}

output "main_vpc_public_subnet_arns_sin" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public_subnet.*.arn
}

output "main_vpc_public_subnets_cidr_blocks_sin" {
  description = "List of cidr_blocks of public subnets"
  value       = local.subnet_map["sin"]["aws_public_subnets"]
}

output "main_vpc_public_route_table_ids_sin" {
  description = "List of IDs of public route tables"
  value       = module.main_vpc_sin.public_route_table_ids
}

output "main_vpc_public_route_table_association_ids_sin" {
  description = "List of IDs of the public route table association"
  value       = module.main_vpc_sin.public_route_table_association_ids
}

output "main_vpc_public_network_acl_id_sin" {
  description = "ID of the public network ACL"
  value       = module.main_vpc_sin.public_network_acl_id
}

output "main_vpc_public_network_acl_arn_sin" {
  description = "ARN of the public network ACL"
  value       = module.main_vpc_sin.public_network_acl_arn
}

output "main_vpc_public_internet_gateway_route_id_sin" {
  description = "ID of the internet gateway route"
  value       = module.main_vpc_sin.public_internet_gateway_route_id
}

# VPC flow log
output "main_vpc_flow_log_id_sin" {
  description = "The ID of the Flow Log resource"
  value       = module.main_vpc_sin.vpc_flow_log_id
}

output "main_vpc_flow_log_destination_arn_sin" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = module.main_vpc_sin.vpc_flow_log_destination_arn
}

output "main_vpc_flow_log_destination_type_sin" {
  description = "The type of the destination for VPC Flow Logs"
  value       = module.main_vpc_sin.vpc_flow_log_destination_type
}

output "main_private_s3_id_sin" {
  description = "main_private_s3 id"
  value       = module.s3_vpc_endpoints_sin.main_private_vpc_id
}
output "main_private_s3_arn_sin" {
  description = "main_private_s3 arn"
  value       = module.s3_vpc_endpoints_sin.main_private_vpc_arn
}
output "main_private_s3_cidr_sin" {
  description = "main_private_s3 cidr exposed"
  value       = module.s3_vpc_endpoints_sin.main_private_vpc_cidr
}

output "main_private_dynamodb_id_sin" {
  description = "main_private_dynamodb id"
  value       = module.dynamodb_vpc_endpoints_sin.main_private_vpc_id
}
output "main_private_dynamodb_arn_sin" {
  description = "main_private_dynamodb arn"
  value       = module.dynamodb_vpc_endpoints_sin.main_private_vpc_arn
}
output "main_private_dynamodb_cidr_sin" {
  description = "main_private_dynamodb cidr exposed"
  value       = module.dynamodb_vpc_endpoints_sin.main_private_vpc_cidr
}

output "main_vpc_igw_id_sin" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "main_vpc_igw_arn_sin" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.igw.arn
}

output "main_vpc_firewall_route_table_ids_sin" {
  description = "List of ID of firewall route tables"
  value       = aws_route_table.firewall_route_table.id
}

output "main_vpc_firewall_subnets_sin" {
  description = "List of IDs of firewall subnets"
  value       = aws_subnet.firewall_subnet.*.id
}

output "main_vpc_msk_route_table_ids_sin" {
  description = "List of ID of MSK route tables"
  value       = aws_route_table.msk_route_table.id
}

output "main_vpc_msk_subnets_sin" {
  description = "List of IDs of MSK subnets"
  value       = aws_subnet.msk_subnet.*.id
}

output "main_vpc_msk_subnets_cidr_blocks_sin" {
  description = "List of cidr_blocks of msk subnets"
  value       = aws_subnet.msk_subnet[*].cidr_block
}

output "main_vpc_elasticache_route_table_ids_sin" {
  description = "List of ID of ElastiCache route tables"
  value       = aws_route_table.elasticache_route_table.id
}

output "main_vpc_elasticache_subnets_sin" {
  description = "List of IDs of ElastiCache subnets"
  value       = aws_subnet.elasticache_subnet.*.id
}

output "main_vpc_elasticache_subnets_cidr_blocks_sin" {
  description = "List of cidr_blocks of ElastiCache subnets"
  value       = aws_subnet.elasticache_subnet[*].cidr_block
}