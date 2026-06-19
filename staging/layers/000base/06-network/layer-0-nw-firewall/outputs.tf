
output "endpoint_id_az" {
  description = "EndPoint ID of Network firewall"
  value       = module.network_firewall.endpoint_id_az
}

output "endpoint_id_az_list" {
  description = "Network firewall EndPoint arranged - ap-southeast-1a, ap-southeast-1b, ap-southeast-1c"
  #value       = [module.network_firewall.endpoint_id_az.ap-southeast-1a, module.network_firewall.endpoint_id_az.ap-southeast-1b, module.network_firewall.endpoint_id_az.ap-southeast-1c]
  value = [module.network_firewall.endpoint_id_az.ap-southeast-1a]
}

output "network_firewall_arn" {
  description = "Network Firewall ARN"
  value       = module.network_firewall.arn
}

output "public_route_table_ids" {
  description = "Public Route Tables per AZ for Network Firewall"
  value       = aws_route_table.public_subnets_to_nfw.*.id
}
