# output "exberry-admin-api" {
#   description = "Endpoint for exberry-admin-api"
#   value       = aws_vpc_endpoint.exberry-admin-api.id
# }
# output "exberry-exchange-api" {
#   description = "Endpoint for exberry-exchange-api"
#   value       = aws_vpc_endpoint.exberry-exchange-api.id
# }

# output "exberry-fix-gateway" {
#   description = "Endpoint for exberry-fix-gateway"
#   value       = aws_vpc_endpoint.exberry-fix-gateway.id
# }

# output "exberry-api-gateway" {
#   description = "Endpoint for exberry-api-gateway"
#   value       = aws_vpc_endpoint.exberry-api-gateway.id
# }
data "aws_network_interface" "exberry_admin_api_eni" {
  for_each = toset(aws_vpc_endpoint.exberry-admin-api-uat-test.network_interface_ids)
  id       = each.value
}

output "exberry_admin_api_private_ips" {
  value = [for eni in data.aws_network_interface.exberry_admin_api_eni : eni.private_ip]
}

data "aws_network_interface" "exberry_exchange_api_eni" {
  for_each = toset(aws_vpc_endpoint.exberry-exchange-api-uat-test.network_interface_ids)
  id       = each.value
}

output "exberry_exchange_api_private_ips" {
  value = [for eni in data.aws_network_interface.exberry_exchange_api_eni : eni.private_ip]
}

data "aws_network_interface" "exberry_fix_gateway_eni" {
  for_each = toset(aws_vpc_endpoint.exberry-fix-gateway-uat-test.network_interface_ids)
  id       = each.value
}

output "exberry_fix_gateway_private_ips" {
  value = [for eni in data.aws_network_interface.exberry_fix_gateway_eni : eni.private_ip]
}

data "aws_network_interface" "exberry_api_gateway_eni" {
  for_each = toset(aws_vpc_endpoint.exberry-api-gateway-uat-test.network_interface_ids)
  id       = each.value
}

output "exberry_api_gateway_private_ips" {
  value = [for eni in data.aws_network_interface.exberry_api_gateway_eni : eni.private_ip]
}
