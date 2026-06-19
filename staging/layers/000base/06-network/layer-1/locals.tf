locals {
  # vpc_peer_tags_sin = {
  #   
  #   purpose = "Main to DB VPC Peering"
  # }

  #Network Access Control List Tags    
  public_nacl_tags_sin = {

    Name    = "${local.env}-public-sin"
    purpose = "NACL for public subnet"

  }
  private_nacl_tags_sin = {

    Name    = "${local.env}-private-sin"
    purpose = "NACL for private subnet"

  }
  db_nacl_tags_sin = {

    Name    = "${local.env}-db-sin"
    purpose = "NACL for DB subnet"

  }
  msk_nacl_tags_sin = {

    Name    = "${local.env}-msk-sin"
    purpose = "NACL for MSK subnet"

  }
  elasticache_nacl_tags_sin = {

    Name    = "${local.env}-elasticache-sin"
    purpose = "NACL for ElastiCache subnet"

  }
  #Security Group Tags      
  vm_sg_tags_sin = {

    Name    = "${local.env}-vm-sin"
    purpose = "Security Group for EC2"

  }
  rds_proxy_sg_tags_sin = {

    Name    = "${local.env}-rds-proxy-sin"
    purpose = "Security Group for RDS Proxy"

  }
  rds_sg_tags_sin = {

    Name    = "${local.env}-rds-sin"
    purpose = "Security Group for RDS DB"

  }
  ec2_teleport_db_sg_tags_sin = {

    Name    = "${local.env}-ec2-teleport-db-sin"
    purpose = "Security Group for EC2 Teleport DB Service"

  }
  ec2_cronicle_sg_tags_sin = {

    Name    = "${local.env}-ec2-cronicle-sin"
    purpose = "Security Group for EC2 Cronicle Service"

  }
  efs_cronicle_sg_tags_sin = {
    Name    = "${local.env}-efs-cronicle-sin"
    purpose = "Security Group for EFS used by Cronicle"
  }

  elastic_agent_sg_tags_sin = {
    Name    = "${local.env}-elastic-agent"
    purpose = "Security Group for Elastic Agent"
  }

  elastic_cloud_sin = {
    Name    = "${local.env}-elastic-cloud-vpce"
    purpose = "Security Group for Elastic Cloud VPCE"
  }

  test_ext_ec2_sg_tags_sin = {

    Name    = "${local.env}-test-ext-ec2-vm"
    purpose = "Security Group for test EC2"

  }
  test_ec2_sg_tags_sin = {

    Name    = "${local.env}-test-ec2-vm"
    purpose = "Security Group for test EC2"

  }
  interface_vpc_endpoint_sg_tags_sin = {

    Name    = "${local.env}-interface-vpc-sin"
    purpose = "Security Group for Interface VPC Endpoints"

  }

  // MQ NSGs
  mq_internal_sin = {
    Name    = "${local.env}-mq-internal"
    purpose = "Security Group for Internal MQ"
  }
  mq_internal_alb_sin = {
    Name    = "${local.env}-mq-internal-alb"
    purpose = "Security Group for Internal MQ ALB"
  }
  mq_internal_nlb_sin = {
    Name    = "${local.env}-mq-internal-nlb"
    purpose = "Security Group for Internal MQ NLB"
  }
  mq_external_alb_sin = {
    Name    = "${local.env}-mq-external-nlb"
    purpose = "Security Group for External MQ NLB"
  }
  eks_cluster_sg_tags_sin = {
    env          = local.env
    Name         = "${local.env}-eks-cluster-sin"
    purpose      = "Security Group for EKS Cluster"
    map-migrated = "mig46499"
  }
  sftp_sg_tags_sin = {
    # env          = local.env
    Name    = "${local.env}-sftp-sin"
    purpose = "Security Group for SFTP Server"
    # map-migrated = "mig46499"
  }
  exberry_internal_sin = {
    # env          = local.env
    Name    = "${local.env}-exberry-internal"
    purpose = "Security Group for Exberry VPCE"
    # map-migrated = "mig46499"
  }
  eks_alb_external_tags_sin = {
    Name    = "${local.env}-eks-alb-external"
    purpose = "Security Group for EKS ALB External"
  }

  # Cloudflare egress / Spectrum anycast IPv4 prefixes
  cloudflare_ipv4 = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
    "58.185.35.148/32",
  ]
  sftp_internal_ssh_ingress = [
    {
      description = "Allow SSH from AWS-NW CIDR"
      rule        = "ssh-tcp"
      cidr_blocks = join(",", [
        local.subnet_map["sin"]["aws_main_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_vpc_cidr"],
        local.subnet_map["sin"]["aws_nw_dev_vpc_cidr"],
      ])
    }
  ]

}
