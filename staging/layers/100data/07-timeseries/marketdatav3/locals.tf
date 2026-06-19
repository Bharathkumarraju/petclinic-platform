# locals {
#   influxdb_name          = "marketdata"
#   influxdb_instance_type = "db.influx.medium"
#   s3_log_bucket_name     = data.terraform_remote_state.buckets.outputs.marketdata_ts_db_logs_bucket_sin_name

#   vpc_subnet_ids         = data.terraform_remote_state.workload_network.outputs.main_vpc_db_subnets_sin
#   vpc_security_group_ids = [module.influxdb_sg.security_group_id]
#   influxdb_port          = 8181

#   vpc_id = data.terraform_remote_state.workload_network.outputs.main_vpc_id_sin
#   default_ingress_with_cidr_blocks = [
#     {
#       from_port   = local.influxdb_port
#       to_port     = local.influxdb_port
#       protocol    = "tcp"
#       description = "Allow Private Subnet access to ${local.influxdb_name} DB"
#       cidr_blocks = join(",", data.terraform_remote_state.workload_network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
#     },
#     {
#       from_port   = local.influxdb_port
#       to_port     = local.influxdb_port
#       protocol    = "tcp"
#       description = "Allow VPN access to ${local.influxdb_name} DB"
#       cidr_blocks = data.terraform_remote_state.core_network.outputs.main_vpc_cidr_block_sin
#     }
#   ]
#   default_egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]
#   additional_ingress_with_cidr_blocks = []
#   network_state_key = contains(local.prod_env, local.env) ? "network" : "network-dev"
#   bucket_name       = contains(local.prod_env, local.env) ? "abaxx-exch-tf-state" : "abaxx-exch-tf-state-nonprod"
#   prod_env          = ["prod", "shared-resources", "external", "trusted", "network", "infra"]
#   non_prod_env      = ["staging", "uat", "network-dev", "agp"]
# }