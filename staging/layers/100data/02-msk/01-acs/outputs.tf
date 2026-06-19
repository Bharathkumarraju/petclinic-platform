output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = module.acs_kafka.cluster_arn
}

output "cluster_name" {
  description = "MSK Cluster name"
  value       = module.acs_kafka.cluster_name
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates"
  value       = module.acs_kafka.current_version
}

# --- Connection Strings ---

output "bootstrap_brokers_sasl_iam" {
  description = "Comma separated list of one or more hostname:port pairs of SASL/IAM enabled endpoint nodes"
  value       = module.acs_kafka.bootstrap_brokers_sasl_iam
}

output "bootstrap_brokers_tls" {
  description = "Comma separated list of one or more hostname:port pairs of TLS enabled endpoint nodes"
  value       = module.acs_kafka.bootstrap_brokers_tls
}

output "zookeeper_connect_string" {
  description = "Comma separated list of one or more hostname:port pairs to connect to the Apache ZooKeeper cluster"
  value       = module.acs_kafka.zookeeper_connect_string
}

# --- Network & Security ---

output "security_group_id" {
  description = "The ID of the security group created for the MSK cluster"
  value       = module.acs_kafka.security_group_id
}

output "security_group_name" {
  description = "The name of the security group created for the MSK cluster"
  value       = module.acs_kafka.security_group_name
}

output "broker_endpoints" {
  description = "List of the MSK broker DNS endpoints"
  value       = module.acs_kafka.hostnames
}

# --- Storage & Config ---

output "config_arn" {
  description = "Amazon Resource Name (ARN) of the MSK configuration"
  value       = module.acs_kafka.config_arn
}