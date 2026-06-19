
module "dms-sg" {
  source                 = "terraform-aws-modules/security-group/aws"
  version                = "5.3.0"
  name                   = "${local.env}-dms-replication-sg"
  description            = "DMS Replication Instance Security Group"
  vpc_id                 = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  revoke_rules_on_delete = true
  ingress_with_cidr_blocks = [
    {
      description = "Within Subnet"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_private_subnets_cidr_blocks_sin)
    },
    {
      description = "DMS VPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.client_cidr_range
    },
    {
      description = "DMS  AWS-Infra access"
      rule        = "mysql-tcp"
      cidr_blocks = local.aws_infra_private_cidr_range
    }
  ]
  egress_with_cidr_blocks = [
    {
      description = "DMS subnet access"
      rule        = "mysql-tcp"
      cidr_blocks = join(",", data.terraform_remote_state.network.outputs.main_vpc_db_subnets_cidr_blocks_sin)
    },
    {
      description = "DMS VPN access"
      rule        = "mysql-tcp"
      cidr_blocks = local.client_cidr_range
    },
    {
      description = "DMS AWS-Infra access"
      rule        = "mysql-tcp"
      cidr_blocks = local.aws_infra_private_cidr_range
    }
  ]
  tags = local.tags
}
