# Provision Network Firewall only
# Rules need to be pre provisioned in repo abex-aws-cross-network-firewall-rules

module "network_firewall" {
  source        = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/network-firewall/create-network-firewall-only"
  firewall_name = local.subnet_map["sin"]["firewall_name"]
  vpc_id        = local.subnet_map["sin"]["main_vpc_id"]
  prefix        = local.env

  # Attach Policy provisioned from abex-aws-cross-network-firewall-rules
  firewall_policy_arn = data.terraform_remote_state.network-firewall-rules-aws-staging.outputs.network_firewall_policy_arn

  # Subnet IDs to Deploy Network Firewall Endpoints
  subnet_mapping = [
    local.subnet_map["sin"]["main_vpc_firewall_subnets"][0],
    #local.subnet_map["sin"]["main_vpc_firewall_subnets"][1],
    #local.subnet_map["sin"]["main_vpc_firewall_subnets"][2]
  ]

  logging_config = {
    flow = {
      retention_in_days = 90
      bucketName        = local.network_fw_bucket
    },
    alert = {
      retention_in_days = 90
      bucketName        = local.network_fw_bucket
    }
  }

  tags            = local.firewall_tags
  cloudwatch_tags = local.cloudwatch_tags
}
