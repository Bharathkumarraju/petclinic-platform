locals {
  env               = var.env
  prod_env          = ["prod", "shared-resources", "external", "trusted", "network"]
  non_prod_env      = ["staging", "uat", "network-dev", "agp"]
  network_state_key = contains(local.prod_env, local.env) ? "network" : "network-dev"
  bucket_name       = contains(local.prod_env, local.env) ? "abaxx-exch-tf-state-prod" : "abaxx-exch-tf-state-nonprod"

  broker_name        = "abex-${var.broker_prefix}-${local.env}"
  engine_version     = var.engine_version
  instance_type      = var.instance_type
  vpc_id             = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  private_subnet_ids = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin

  mq_ports = {
    amqp         = 5671,
    mqtt         = 8883,
    stomp        = 61614,
    openwire_ssl = 61617,
    openwire     = 61619
  }

  mq_instance_count = contains(local.prod_env, local.env) ? 2 : 1
  mq_target_indices = range(local.mq_instance_count)

  default_ingress_with_cidr_blocks = [
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      description = "Allow ${local.network_state_key} VPC CIDR"
      cidr_blocks = data.terraform_remote_state.core_network.outputs.main_vpc_cidr_block_sin
    },
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      description = "Allow ${local.network_state_key} VPC CIDR"
      cidr_blocks = data.terraform_remote_state.core_network.outputs.main_vpc_cidr_block_sin
    },
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      description = "Allow ${local.network_state_key} VPC CIDR"
      cidr_blocks = data.terraform_remote_state.core_network.outputs.main_vpc_cidr_block_sin
    },
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      description = "Allow ${local.network_state_key} VPC CIDR"
      cidr_blocks = data.terraform_remote_state.core_network.outputs.main_vpc_cidr_block_sin
    },
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      description = "Allow ${local.network_state_key} VPC CIDR"
      cidr_blocks = data.terraform_remote_state.core_network.outputs.main_vpc_cidr_block_sin
    },
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      description = "Allow Private Subnet CIDR"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      description = "Allow Private Subnet CIDR"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      from_port   = 61614
      to_port     = 61614
      protocol    = "tcp"
      description = "Allow Private Subnet CIDR"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      from_port   = 61617
      to_port     = 61617
      protocol    = "tcp"
      description = "Allow Private Subnet CIDR"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      from_port   = 61619
      to_port     = 61619
      protocol    = "tcp"
      description = "Allow Private Subnet CIDR"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    }
  ]
}