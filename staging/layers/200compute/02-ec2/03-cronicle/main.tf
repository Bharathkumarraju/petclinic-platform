module "cronicle_ec2_server_1" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  name = "${local.app_prefix}-01-staging"
  #ami  = local.ami_id
  ami = data.aws_ami.ubuntu_golden_image.id

  instance_type               = local.instance_type
  key_name                    = local.key_name
  monitoring                  = true
  vpc_security_group_ids      = [local.ec2_cronicle_id_sin]
  subnet_id                   = local.main_vpc_private_subnets_sin[0]
  iam_instance_profile        = local.ec2_cronicle_inst_profile_sin
  associate_public_ip_address = false
  private_ip                  = local.server1_private_ip
  enable_volume_tags          = false
  ignore_ami_changes          = true
  root_block_device = [
    {
      volume_size = 50
      encrypted   = true
      kms_key_id  = local.common_kms_key_ec2_ebs_id
    }
  ]
  metadata_options = {
    instance_metadata_tags = "enabled"
  }

  tags = merge(local.tags, {
    "ec2-backup-plan-1" = "true",
    CreatedByTF         = "true",
    ManagedByAnsible    = "true",
    UpgradeToNewAMI     = "false"
  })
}

module "cronicle_ec2_server_2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  name = "${local.app_prefix}-02-staging"
  #ami  = local.ami_id
  ami = data.aws_ami.ubuntu_golden_image.id

  instance_type               = local.instance_type
  key_name                    = local.key_name
  monitoring                  = true
  vpc_security_group_ids      = [local.ec2_cronicle_id_sin]
  subnet_id                   = local.main_vpc_private_subnets_sin[1]
  iam_instance_profile        = local.ec2_cronicle_inst_profile_sin
  associate_public_ip_address = false
  private_ip                  = local.server2_private_ip
  enable_volume_tags          = false
  ignore_ami_changes          = true
  root_block_device = [
    {
      volume_size = 50
      encrypted   = true
      kms_key_id  = local.common_kms_key_ec2_ebs_id
    }
  ]
  metadata_options = {
    instance_metadata_tags = "enabled"
  }

  tags = merge(local.tags, {
    "ec2-backup-plan-1" = "true",
    CreatedByTF         = "true",
    ManagedByAnsible    = "true",
    UpgradeToNewAMI     = "false"
  })
}

# Allow HTTPS access to Cronicle Web Console
module "alb_internal" {
  source                           = "terraform-aws-modules/alb/aws"
  version                          = "~> 8.0"
  load_balancer_type               = "application"
  name                             = "${local.app_prefix}-${local.env}-alb-int"
  vpc_id                           = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  subnets                          = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  security_groups                  = []
  internal                         = true
  drop_invalid_header_fields       = true
  enable_cross_zone_load_balancing = true
  security_group_rules = [
    {
      description = "Allow HTTP access to Cronicle Web Console"
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [local.network_vpc_cidr]

    },
    {
      description = "Allow HTTPS access to Cronicle Web Console"
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [local.network_vpc_cidr]
    },
    // egress to all 
    {
      description = "Allow all egress"
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]


  # HTTPS Listeners
  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     ssl_policy         = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  #     certificate_arn    = local.internal_certificate_arn
  #     target_group_index = 0
  #   },
  # ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]


  target_groups = [
    {
      name_prefix      = "cr80-"
      backend_protocol = "HTTP"
      backend_port     = 3012
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = module.cronicle_ec2_server_1.id
        },
        my_target_2 = {
          target_id = module.cronicle_ec2_server_2.id
        }
      }
      deregistration_delay = 10
      health_check = {
        protocol            = "HTTP"
        enabled             = true
        interval            = 5
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 4
        success_codes       = ["200"]

      }
      stickiness = {
        cookie_duration = 86400
        enabled         = true
        type            = "lb_cookie"
      }
    },
  ]

  tags = local.tags
}
