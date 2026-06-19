###########################
# MQ Broker
###########################
output "mq_broker_id" {
  description = "The ID of the MQ broker"
  value       = aws_mq_broker.mq.id
}

output "mq_broker_arn" {
  description = "The ARN of the MQ broker"
  value       = aws_mq_broker.mq.arn
}

output "mq_broker_instances" {
  description = "The list of broker instances with endpoints"
  value       = aws_mq_broker.mq.instances
}

output "mq_broker_private_ips" {
  description = "The private IP addresses of the MQ broker instances"
  value       = [for instance in aws_mq_broker.mq.instances : instance.ip_address]
}

###########################
# Network Load Balancer
###########################
output "nlb_arn" {
  description = "The ARN of the Network Load Balancer"
  value       = aws_lb.mq_nlb.arn
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer"
  value       = aws_lb.mq_nlb.dns_name
}

output "nlb_private_ips" {
  description = "The private IP addresses of the Network Load Balancer"
  value       = [for eni in data.aws_network_interface.mq_nlb : eni.private_ip]
}

###########################
# Security Group
###########################
output "security_group_id" {
  description = "The ID of the MQ security group"
  value       = module.mq_sg.security_group_id
}
