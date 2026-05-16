output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "rds_sg_id" {
  description = "RDS security group ID — cluster environments add ingress rules for their node SGs"
  value       = aws_security_group.rds.id
}

output "alb_sg_id" {
  description = "ALB security group ID — allows HTTP/HTTPS from internet"
  value       = aws_security_group.alb.id
}
