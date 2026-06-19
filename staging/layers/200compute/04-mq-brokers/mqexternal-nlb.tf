##################################################################
# Network Load Balancer for external access with spectrum
##################################################################

locals {
  nlb_certificate_arn      = "arn:aws:acm:ap-southeast-1:993533333148:certificate/de2311c8-698a-4a09-a367-5dfb330ffaf6"
  mq_external_primary_ip   = module.exchange.external_mq_ip_address[0]
  mq_external_secondary_ip = module.exchange.external_mq_ip_address[1]


  nlb_listeners = {
    # OpenWire - 61617
    openwire-617 = {
      port = 61617
      forward = {
        target_group_key = "openwire-617"
      }
    },
    # STOMP - 61614
    stomp-614 = {
      port = 61614
      forward = {
        target_group_key = "stomp-614"
      }
    },
    # WSS - 61619
    wss-619 = {
      port = 61619
      forward = {
        target_group_key = "wss-619"
      }
    },
    # AMQP - 5761
    amqp-671 = {
      port = 5671
      forward = {
        target_group_key = "amqp-671"
      }
    },
    # MQTT - 8883
    mqtt-883 = {
      port = 8883
      forward = {
        target_group_key = "mqtt-883"
      }
    }
  }
  nlb_target_groups = {
    # OpenWire - 61617
    openwire-617 = {
      name_prefix = "mq617-"
    },
    # STOMP - 61614
    stomp-614 = {
      name_prefix = "mq614-"
    },
    # WSS - 61619
    wss-619 = {
      name_prefix = "mq619-"
    },
    # AMQP - 5761
    amqp-671 = {
      name_prefix = "mq671-"
    },
    # MQTT - 8883
    mqtt-883 = {
      name_prefix = "mq883-"
    },
  }
}

#tfsec:ignore:aws-elb-alb-not-public
module "nlb" {
  source                           = "terraform-aws-modules/alb/aws"
  enable_cross_zone_load_balancing = false
  version                          = "~> 9.16.0"
  load_balancer_type               = "network"
  name                             = "${local.env}-${local.region_prefix}-mq-nlb"
  vpc_id                           = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  subnets                          = data.terraform_remote_state.network.outputs.main_vpc_public_subnets_sin
  create_security_group            = false
  security_groups                  = [local.mq_external_nlb_sg_id_sin]
  internal                         = false
  enable_deletion_protection       = true

  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  access_logs = {
    bucket = local.lb_access_logs_bucket_name
    prefix = "${local.env}-${local.region_prefix}-mq-nlb"
  }
  # TLS Listeners
  listeners = {
    for k, v in local.nlb_listeners : k => merge({
      protocol        = "TLS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = local.nlb_certificate_arn
      tags = {
        Name = k
      }
    }, v)
  }

  # Target groups
  target_groups = {
    for k, v in local.nlb_target_groups : k => merge({
      port                 = local.nlb_listeners[k].port
      protocol             = "TLS"
      target_id            = local.mq_external_primary_ip
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        protocol            = "TCP"
        enabled             = true
        interval            = 5
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 4
      }
      tags = {
        Name = "${k}-primary"
      }
    }, v)
  }
  additional_target_group_attachments = {
    for k, v in local.nlb_target_groups : "${k}-secondary" => merge({
      target_group_key = k
      target_id        = local.mq_external_secondary_ip
      port             = local.nlb_listeners[k].port
      tags = {
        Name = "${k}-secondary"
      }
    })
  }

  tags = {
    Name = "${local.env}-${local.region_prefix}-mq-nlb"
  }
}

module "nlb-internal" {
  source                           = "terraform-aws-modules/alb/aws"
  enable_cross_zone_load_balancing = true
  version                          = "~> 9.16.0"
  load_balancer_type               = "network"
  name                             = "${local.env}-${local.region_prefix}-mq-nlb-int"
  vpc_id                           = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  subnets                          = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  create_security_group            = false
  security_groups                  = [local.mq_internal_nlb_sg_id_sin]
  internal                         = true
  enable_deletion_protection       = true
  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  access_logs = {
    bucket = local.lb_access_logs_bucket_name
    prefix = "${local.env}-${local.region_prefix}-mq-nlb-int"
  }
  # TLS Listeners
  listeners = {
    for k, v in local.nlb_listeners : k => merge({
      protocol        = "TLS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = local.nlb_certificate_arn

      additional_certificate_arns = [data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_ap_southeast_1_arn]

      tags = {
        Name = k
      }
    }, v)
  }

  # Target groups
  target_groups = {
    for k, v in local.nlb_target_groups : k => merge({
      port                 = local.nlb_listeners[k].port
      protocol             = "TLS"
      target_id            = local.mq_external_primary_ip
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        protocol            = "TCP"
        enabled             = true
        interval            = 5
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 4
      }
      tags = {
        Name = "${k}-primary"
      }
    }, v)
  }
  additional_target_group_attachments = {
    for k, v in local.nlb_target_groups : "${k}-secondary" => {
      target_group_key = k
      target_id        = local.mq_external_secondary_ip
      port             = local.nlb_listeners[k].port
      tags = {
        Name = "${k}-secondary"
      }
    }
  }

  tags = {
    Name = "${local.env}-${local.region_prefix}-mq-nlb-int"
  }
}

######################################
# MQ Public Internal NLB
######################################
locals {
  mq_staging_external_integration_targets = toset(module.exchange.external_mq_ip_address)
  mq_ports = {
    amqp         = 5671
    mqtt         = 8883
    stomp        = 61614
    openwire_ssl = 61617
    openwire     = 61619
  }
  mq_certificate_arn = data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_ap_southeast_1_arn
}
resource "aws_lb" "mq_public_int_nlb_aps1_staging" {
  name                             = "${local.env}-${local.region_prefix}-mq-public-int-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  security_groups                  = [local.mq_internal_nlb_sg_id_sin]
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
}

resource "aws_cloudwatch_log_delivery_source" "mq_public_int_nlb_aps1_staging_logging_source" {
  name         = "mq-public-int-nlb-aps1-staging"
  log_type     = "NLB_ACCESS_LOGS"
  resource_arn = aws_lb.mq_public_int_nlb_aps1_staging.arn
}

resource "aws_cloudwatch_log_delivery_destination" "mq_public_int_nlb_aps1_staging_logging_destination" {
  name = "mq-public-int-nlb-aps1-staging-logs-s3-destination"

  delivery_destination_configuration {
    destination_resource_arn = data.terraform_remote_state.bucket.outputs.loadbalancer_bucket_sin_arn
  }
}

resource "aws_cloudwatch_log_delivery" "mq_public_int_nlb_aps1_staging_logging" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.mq_public_int_nlb_aps1_staging_logging_source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.mq_public_int_nlb_aps1_staging_logging_destination.arn

  s3_delivery_configuration {
    suffix_path                 = "mq-public-int-nlb-aps1-staging/{yyyy}/{MM}/{dd}/"
    enable_hive_compatible_path = true
  }
}

resource "aws_lb_target_group" "mq_public_int_nlb_aps1_staging" {
  for_each = local.mq_ports

  name        = "mq-public-int-nlb-${each.value}"
  port        = each.value
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  stickiness {
    type    = "source_ip"
    enabled = false
  }
}

resource "aws_lb_listener" "mq_public_int_nlb_aps1_staging_listener" {
  for_each = local.mq_ports

  load_balancer_arn = aws_lb.mq_public_int_nlb_aps1_staging.arn
  port              = each.value
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = local.mq_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mq_public_int_nlb_aps1_staging[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "mq_public_int_nlb_aps1_staging_attachment" {
  for_each = {
    for pair in flatten([
      for port_key, port_val in local.mq_ports : [
        for target_ip in local.mq_staging_external_integration_targets : {
          key      = "${port_key}-${target_ip}"
          port     = port_val
          port_key = port_key
          ip       = target_ip
        }
      ]
    ]) : pair.key => pair
  }

  target_group_arn = aws_lb_target_group.mq_public_int_nlb_aps1_staging[each.value.port_key].arn
  target_id        = each.value.ip
  port             = each.value.port
}