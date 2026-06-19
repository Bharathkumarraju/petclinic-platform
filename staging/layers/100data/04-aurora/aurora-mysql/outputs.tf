output "claradb_proxy_endpoints" {
  value = module.claradb-rds-proxy.proxy_endpoint
}

output "claradb_proxy_arn" {
  value = module.claradb-rds-proxy.proxy_arn
}

output "claradb_proxy_custom_endpoints" {
  description = "Custom proxy endpoints (read_write and read_only)"
  value       = module.claradb-rds-proxy.db_proxy_endpoints
}

output "aurora_cluster_members" {
  value = {
    for idx, val in tolist(module.exchangedb.cluster_members) :
    idx => val
  }
}

output "proxy_identifier" {
  // arn reference "arn:aws:rds:ap-southeast-1:993533333148:db-proxy:prx-0c0386aa2f1cac7ae"
  value = split(":", module.claradb-rds-proxy.proxy_arn)[6]
}
