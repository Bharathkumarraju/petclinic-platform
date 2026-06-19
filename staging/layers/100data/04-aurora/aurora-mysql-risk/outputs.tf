output "riskdb_proxy_endpoints" {
  value = module.riskdb-rds-proxy.proxy_endpoint
}

output "riskdb_proxy_arn" {
  value = module.riskdb-rds-proxy.proxy_arn
}

output "riskdb_proxy_custom_endpoints" {
  description = "Custom proxy endpoints (read_write and read_only)"
  value       = module.riskdb-rds-proxy.db_proxy_endpoints
}

output "aurora_cluster_members" {
  value = {
    for idx, val in tolist(module.riskdb.cluster_members) :
    idx => val
  }
}

output "cluster_resource_id" {
  value = module.riskdb.cluster_resource_id
}

output "proxy_identifier" {
  // arn reference "arn:aws:rds:ap-southeast-1:993533333148:db-proxy:prx-0c0386aa2f1cac7ae"
  value = split(":", module.riskdb-rds-proxy.proxy_arn)[6]
}
