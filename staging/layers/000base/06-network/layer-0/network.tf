locals {
  s3_service_map          = module.common.s3_service_map
  dynamodb_service_map    = module.common.dynamodb_service_map
  vpc_flow_log_format     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${srcport} $${dstaddr} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id}"
  vpc_flow_log_bucket_arn = data.terraform_remote_state.bucket.outputs.vpc_flow_bucket_sin_arn

  main_eip_allocations_ids_sin = data.terraform_remote_state.network-pre.outputs.eip_allocations_ids_sin
  #  main_vpc_flow_log_sin        = data.terraform_remote_state.cloudwatch-logs.outputs.main_vpc_flow_log_group_sin
  cloudwatch_log_role_arn_sin = data.terraform_remote_state.cloudwatch-logs-role.outputs.vpc_flow_log_service_role_sin.arn

  default_network_acl_ingress = [
    { "action" : "deny", "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_no" : 100, "to_port" : 0 }
  ]

  default_db_acl_ingress = [
    { "cidr_block" : "0.0.0.0/0", "from_port" : 0, "protocol" : "-1", "rule_action" : "deny", "rule_number" : 100, "to_port" : 0 }
  ]

  # Shared network
  aws_admin_cidr_range_map = {
    network          = "172.23.0.0/16"
    infra            = "172.21.0.0/16"
    shared-resources = "172.22.0.0/16"
  }

  # Overall IP Address CIDR reserved per environment catered for future
  aws_cidr_range_map = {
    staging  = "10.40.0.0/13"
    pre-prod = "10.56.0.0/13"
    prod     = "10.64.0.0/13"
  }

  # Use /17 for the start for the main AWS Account CIDR range
  aws_main_vpc_cidr_range = cidrsubnet(local.aws_cidr_range_map[local.env], 4, 0)

  # Use /19 for the start for the main AWS Account CIDR range
  aws_network_vpc_cidr_range          = cidrsubnet(local.aws_admin_cidr_range_map["network"], 3, 0)
  aws_infra_vpc_cidr_range            = cidrsubnet(local.aws_admin_cidr_range_map["infra"], 3, 0)
  aws_shared_resources_vpc_cidr_range = cidrsubnet(local.aws_admin_cidr_range_map["shared-resources"], 3, 0)
  aws_staging_vpc_cidr_range          = cidrsubnet(local.aws_cidr_range_map["staging"], 4, 0)
  aws_pre_prod_vpc_cidr_range         = cidrsubnet(local.aws_cidr_range_map["pre-prod"], 4, 0)
  aws_prod_vpc_cidr_range             = cidrsubnet(local.aws_cidr_range_map["prod"], 4, 0)
  aws_risk_sb_main_vpc_cidr           = "10.48.128.0/19"

  subnet_map = {
    sin = {
      main_vpc_name                    = "${local.env}-main-sin"
      aws_main_vpc_cidr                = cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0)
      aws_azs                          = ["${local.region_map["sin"]}a", "${local.region_map["sin"]}b", "${local.region_map["sin"]}c"]
      aws_public_subnets               = cidrsubnets(cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 3, 0), 2, 2, 2)
      aws_public_subnet_suffix         = "${local.env}-sin-public"
      aws_public_subnet_names          = ["${local.env}-main-sin-public-${local.region_map["sin"]}a", "${local.env}-main-sin-public-${local.region_map["sin"]}b", "${local.env}-main-sin-public-${local.region_map["sin"]}c"]
      aws_db_subnets                   = cidrsubnets(cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 3, 1), 2, 2, 2)
      aws_db_subnet_suffix             = "${local.env}-sin-db"
      aws_private_subnets              = cidrsubnets(cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 2, 1), 2, 2, 2)
      aws_private_subnet_suffix        = "${local.env}-sin-private"
      aws_firewall_subnets             = cidrsubnets(cidrsubnet(cidrsubnet(local.aws_main_vpc_cidr_range, 2, 0), 6, 32), 2, 2, 2)
      aws_firewall_subnet_names        = ["${local.env}-main-sin-firewall-${local.region_map["sin"]}a", "${local.env}-main-sin-firewall-${local.region_map["sin"]}b", "${local.env}-main-sin-firewall-${local.region_map["sin"]}c"]
      aws_firewall_route_table_name    = "${local.env}-main-sin-firewall"
      aws_msk_subnets                  = ["10.40.17.0/24", "10.40.18.0/24", "10.40.19.0/24"]
      aws_msk_subnet_names             = ["${local.env}-main-sin-msk-${local.region_map["sin"]}a", "${local.env}-main-sin-msk-${local.region_map["sin"]}b", "${local.env}-main-sin-msk-${local.region_map["sin"]}c"]
      aws_msk_route_table_name         = "${local.env}-main-sin-msk"
      aws_elasticache_subnets          = ["10.40.16.96/27", "10.40.16.128/27", "10.40.16.160/27"]
      aws_elasticache_subnet_names     = ["${local.env}-main-sin-elasticache-${local.region_map["sin"]}a", "${local.env}-main-sin-elasticache-${local.region_map["sin"]}b", "${local.env}-main-sin-elasticache-${local.region_map["sin"]}c"]
      aws_elasticache_route_table_name = "${local.env}-main-sin-elasticache"
      main_vpc_flow_log_role_arn = local.cloudwatch_log_role_arn_sin
      main_eip_allocations_ids   = local.main_eip_allocations_ids_sin
    }
  }
}
