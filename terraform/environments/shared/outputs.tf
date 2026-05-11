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
