###########################
# MQ Broker
###########################
output "mq_broker_id" {
  description = "The ID of the MQ broker"
  value       = module.mq_external.mq_broker_id
}

output "mq_broker_arn" {
  description = "The ARN of the MQ broker"
  value       = module.mq_external.mq_broker_arn
}

output "mq_broker_instances" {
  description = "The list of MQ broker instances with endpoints"
  value       = module.mq_external.mq_broker_instances
}

output "mq_broker_private_ips" {
  description = "The private IP addresses of the MQ broker instances"
  value       = module.mq_external.mq_broker_private_ips
}

###########################
# Network Load Balancer
###########################
output "nlb_arn" {
  description = "The ARN of the Network Load Balancer"
  value       = module.mq_external.nlb_arn
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = module.mq_external.nlb_dns_name
}

output "nlb_private_ips" {
  description = "The private IP addresses of the Network Load Balancer"
  value       = module.mq_external.nlb_private_ips
}

###########################
# Security Group
###########################
output "security_group_id" {
  description = "The ID of the MQ security group"
  value       = module.mq_external.security_group_id
}

