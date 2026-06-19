output "internal_mq_endpoints" {
  value = module.exchange.internal_mq_endpoints
}

output "internal_mq_console_url" {
  value = module.exchange.internal_mq_console_url
}

output "external_mq_endpoints" {
  value = module.exchange.external_mq_endpoints
}

output "external_mq_console_url" {
  value = module.exchange.external_mq_console_url
}

output "internal_mq_ip_address" {
  value = module.exchange.internal_mq_ip_address
}

output "external_mq_ip_address" {
  value = module.exchange.external_mq_ip_address
}


output "internal_mq_broker_id" {
  value = module.exchange.mq_internal_broker_id
}

output "external_mq_broker_id" {
  value = module.exchange.mq_external_broker_id
}

output "mq_nlb_arn" {
  description = "ARN of the external MQ NLB"
  value       = module.nlb.arn
}

output "mq_nlb_internal_arn" {
  description = "ARN of the internal MQ NLB"
  value       = module.nlb-internal.arn
}

output "mq_alb_internal_arn" {
  description = "ARN of the internal MQ ALB"
  value       = module.alb_internal.arn
}

# Obtain private IPs of mq-internal NLB
data "aws_network_interfaces" "mq_internal_nlb" {
  filter {
    name   = "description"
    values = ["ELB net/${local.env}-${local.region_prefix}-mq-nlb-int/*"]
  }
}

data "aws_network_interface" "mq_internal_nlb" {
  for_each = toset(data.aws_network_interfaces.mq_internal_nlb.ids)

  id = each.value
}

output "mq_internal_nlb_private_ips" {
  value = [
    for eni in data.aws_network_interface.mq_internal_nlb :
    eni.private_ip
  ]
}


output "mq_public_int_nlb_aps1_staging_arn" {
  description = "ARN of the MQ public internal NLB"
  value       = aws_lb.mq_public_int_nlb_aps1_staging.arn
}

output "mq_public_int_nlb_aps1_staging_dns_name" {
  description = "DNS name of the MQ public internal NLB"
  value       = aws_lb.mq_public_int_nlb_aps1_staging.dns_name
}

# Obtain private IPs of mq-public-int-nlb
data "aws_network_interfaces" "mq_public_int_nlb" {
  filter {
    name   = "description"
    values = ["ELB net/${local.env}-${local.region_prefix}-mq-public-int-nlb/*"]
  }
}

data "aws_network_interface" "mq_public_int_nlb" {
  for_each = toset(data.aws_network_interfaces.mq_public_int_nlb.ids)

  id = each.value
}

output "mq_public_int_nlb_private_ips" {
  value = [
    for eni in data.aws_network_interface.mq_public_int_nlb :
    eni.private_ip
  ]
}