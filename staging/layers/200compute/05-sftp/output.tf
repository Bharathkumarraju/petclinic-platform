output "arn" {
  value       = aws_transfer_server.public.*.arn
  description = "ARN of transfer server"
}
output "id" {
  value       = local.server_id
  description = "ID of transfer server"
}
output "endpoint" {
  value       = local.server_ep
  description = "Endpoint of transfer server"
}
output "domain_name" {
  value       = local.sftp_ext_domain #"${local.sftp_sub_domain}-${local.env}.${local.hosted_zone}"
  description = "Custom DNS name mapped in Route53 for transfer server"
}

# Obtain private IPs of the transfer server's ENIs
data "aws_network_interfaces" "transfer_server" {
  depends_on = [aws_transfer_server.public]

  filter {
    name   = "vpc-id"
    values = [local.main_vpc_id_sin]
  }

  filter {
    name   = "subnet-id"
    values = aws_transfer_server.public.endpoint_details[0].subnet_ids
  }

  filter {
    name   = "description"
    values = ["*${aws_transfer_server.public.endpoint_details[0].vpc_endpoint_id}*"]
  }
}

data "aws_network_interface" "transfer_server" {
  for_each = toset(data.aws_network_interfaces.transfer_server.ids)
  id       = each.value
}

output "transfer_server_private_ips" {
  value = [for eni in data.aws_network_interface.transfer_server : eni.private_ip]
}