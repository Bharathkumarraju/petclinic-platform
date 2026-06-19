##########################
# Replication Group
##########################

output "redis_replication_group_id" {
  description = "Redis cluster ID."
  value       = module.acs_redis.replication_group_id
}

output "redis_replication_group_arn" {
  description = "ARN of the ElastiCache replication group."
  value       = module.acs_redis.replication_group_arn
}

output "redis_engine_version_actual" {
  description = "The running version of the cache engine."
  value       = module.acs_redis.engine_version_actual
}

output "redis_member_clusters" {
  description = "Redis cluster members."
  value       = module.acs_redis.member_clusters
}

output "redis_cluster_enabled" {
  description = "Indicates if cluster mode is enabled."
  value       = module.acs_redis.cluster_enabled
}

output "redis_port" {
  description = "Redis port."
  value       = module.acs_redis.port
}

##########################
# Endpoints
##########################
output "redis_acs_user_group_id" {
  description = "ID of the ElastiCache user group."
  value       = module.acs_redis.redis_acs_user_group_id
}

output "redis_acs_user_group_arn" {
  description = "ARN of the ElastiCache user group."
  value       = module.acs_redis.redis_acs_user_group_arn
}

output "redis_elasticache_users" {
  description = "Map of all ElastiCache users with their IDs and ARNs."
  value       = module.acs_redis.elasticache_users
}

output "redis_elasticache_user_ids" {
  description = "List of all ElastiCache user IDs."
  value       = module.acs_redis.elasticache_user_ids
}

##########################
# CloudWatch Log Groups
##########################

output "redis_slow_log_group_name" {
  description = "Name of the CloudWatch log group for Redis slow logs."
  value       = module.acs_redis.slow_log_group_name
}

output "redis_slow_log_group_arn" {
  description = "ARN of the CloudWatch log group for Redis slow logs."
  value       = module.acs_redis.slow_log_group_arn
}

output "redis_engine_log_group_name" {
  description = "Name of the CloudWatch log group for Redis engine logs."
  value       = module.acs_redis.engine_log_group_name
}

output "redis_engine_log_group_arn" {
  description = "ARN of the CloudWatch log group for Redis engine logs."
  value       = module.acs_redis.engine_log_group_arn
}

##########################
# KMS Key
##########################

output "redis_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt Redis data at rest."
  value       = module.acs_redis.kms_key_arn
}

output "redis_kms_key_alias" {
  description = "Alias of the KMS key."
  value       = module.acs_redis.kms_key_alias
}
