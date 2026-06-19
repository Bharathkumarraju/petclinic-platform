##################################################################
# Application Load Balancer -Internal
##################################################################

locals {
  internal_certificate_arn = "arn:aws:acm:ap-southeast-1:993533333148:certificate/cf03fb37-f2d1-4342-a100-ca2667eb3641"

  mq_primary_ip   = module.exchange.internal_mq_ip_address[0]
  mq_secondary_ip = module.exchange.internal_mq_ip_address[1]

  alb_target_groups = {
    mq-admin-int = {
      name_prefix = "mq443-"
      target_id   = local.mq_primary_ip
    },
    mq-admin-ext = {
      name_prefix = "mq443-"
      target_id   = local.mq_external_primary_ip
    },
  }
  alb_secondary_target_groups = {
    mq-admin-int = {
      target_id = local.mq_secondary_ip
    },
    mq-admin-ext = {
      target_id = local.mq_external_secondary_ip
    },
  }
}

# Use to access ActiveMQ Web Console
module "alb_internal" {
  source                     = "terraform-aws-modules/alb/aws"
  enable_xff_client_port     = true
  version                    = "~> 9.16"
  load_balancer_type         = "application"
  name                       = "${local.env}-${local.region_prefix}-mq-alb-internal"
  vpc_id                     = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  subnets                    = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  security_groups            = [local.mq_internal_alb_sg_id_sin]
  internal                   = true
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  access_logs = {
    bucket = local.lb_access_logs_bucket_name
    prefix = "${local.env}-${local.region_prefix}-mq-alb-internal"
  }
  # HTTPS Listeners
  listeners = {
    https = {
      port               = 443
      protocol           = "HTTPS"
      ssl_policy         = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn    = local.internal_certificate_arn
      target_group_index = 0
      forward = {
        target_group_key = "mq-admin-int"
      }
      rules = {
        forward-int = {
          priority = 1

          actions = [
            {
              type             = "forward"
              target_group_key = "mq-admin-int"
            }
          ]
          conditions = [{
            host_header = {
              values = ["mq-admin.staging.abex.int"]
            }
          }]
        }
        forward-ext = {
          priority = 2

          actions = [
            {
              type             = "forward"
              target_group_key = "mq-admin-ext"
            }
          ]
          conditions = [{
            host_header = {
              values = ["mq-admin-ext.staging.abex.int"]
            }
          }]
        }
      }

    }
  }

  target_groups = {
    for k, v in local.alb_target_groups : k => merge({
      port                 = 8162
      protocol             = "HTTPS"
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        protocol            = "HTTPS"
        enabled             = true
        interval            = 5
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 4
        matcher             = "200-302"
      }
      tags = {
        Name = "${k}-primary"
      }
    }, v)
  }
  additional_target_group_attachments = {
    for k, v in local.alb_secondary_target_groups : "${k}-secondary" => merge({
      target_group_key = k
      port             = 8162
      tags = {
        Name = "${k}-secondary"
      }
    }, v)
  }

  tags = {
    Name = "${local.env}-${local.region_prefix}-mq-alb-internal"
  }
}

