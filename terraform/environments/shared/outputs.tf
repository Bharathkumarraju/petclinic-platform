output "vpc_id" {
  description = "Shared VPC ID — referenced by linkerd, istio, cilium environments"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs shared across all 3 mesh clusters"
  value       = module.vpc.public_subnet_ids
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "rds_sg_id" {
  description = "Shared RDS security group ID — cluster environments add their node SG ingress rule here"
  value       = module.vpc.rds_sg_id
}

output "alb_sg_id" {
  description = "Shared ALB security group ID"
  value       = module.vpc.alb_sg_id
}

output "rds_endpoint" {
  description = "RDS instance endpoint hostname — used by cluster environments for DB connection strings"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "RDS instance port (3306)"
  value       = module.rds.port
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN for RDS credentials (username, password, host, port, dbname)"
  value       = module.rds.secret_arn
}

output "rds_connection_string" {
  description = "JDBC connection string for the petclinic database"
  value       = module.rds.connection_string
}

output "ecr_repository_urls" {
  description = "Map of service_name → ECR repository URL (shared across all clusters)"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "Map of service_name → ECR repository ARN"
  value       = module.ecr.repository_arns
}

output "certificate_arn" {
  description = "ACM wildcard certificate ARN for *.kube-hub.com (shared across all 3 clusters)"
  value       = module.dns.certificate_arn
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID for kube-hub.com"
  value       = module.dns.zone_id
}
