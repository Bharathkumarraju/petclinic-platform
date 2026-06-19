locals {
  name           = "abex-redis-acs-${local.env}"
  description    = "Redis cluster for ACS in ${local.env} environment"
  engine_version = "7.1"
  instance_type  = "cache.t3.medium"
  additional_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = ["172.24.0.0/21"]
      description = "Allow inbound from VPN CIDR"
    }
  ]
}