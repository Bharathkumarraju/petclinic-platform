output "sharedpsql_db" {
  value = module.postgres
}
# output "claradb_proxy_arn" {
#   value = module.claradb-rds-proxy.proxy_arn
# }
# output "aurora_cluster_members" {
#   value = {
#     for idx, val in tolist(module.exchangedb.cluster_members) :
#     idx => val
#   }
# }

# output "proxy_identifier" {
#   // arn reference "arn:aws:rds:ap-southeast-1:993533333148:db-proxy:prx-0c0386aa2f1cac7ae"
#   value = split(":", module.claradb-rds-proxy.proxy_arn)[6]
# }
