###########################
# MQ Broker (Private subnet)
###########################
resource "aws_mq_broker" "mq" {
  engine_type = "ActiveMQ"

  deployment_mode = contains(local.prod_env, local.env) ? "ACTIVE_STANDBY_MULTI_AZ" : "SINGLE_INSTANCE"
  storage_type    = "efs"

  broker_name                = local.broker_name
  engine_version             = local.engine_version
  host_instance_type         = local.instance_type
  auto_minor_version_upgrade = true

  user {
    username       = jsondecode(aws_secretsmanager_secret_version.mq_admin.secret_string)["username"]
    password       = jsondecode(aws_secretsmanager_secret_version.mq_admin.secret_string)["password"]
    console_access = true
    groups         = ["activemq-webconsole", "admin-group"]
  }

  dynamic "user" {
    for_each = var.mq_users
    content {
      username       = user.value.username
      password       = random_password.mq_user[user.value.username].result
      console_access = user.value.console_access
      groups         = user.value.groups
    }
  }

  configuration {
    id       = aws_mq_configuration.mq.id
    revision = aws_mq_configuration.mq.latest_revision
  }

  logs {
    general = true
    audit   = true
  }

  publicly_accessible = false
  subnet_ids          = contains(local.prod_env, local.env) ? slice(local.private_subnet_ids, 0, 2) : slice(local.private_subnet_ids, 0, 1)

  security_groups = [module.mq_sg.security_group_id]

  # KMS encryption settings
  encryption_options {
    use_aws_owned_key = false
    kms_key_id        = data.terraform_remote_state.kms_mq.outputs.kms_key_mq_sin["arn"]
  }

  # Maintenance Window
  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "00:00"
    time_zone   = "UTC"
  }
}

resource "aws_mq_configuration" "mq" {
  description    = "${local.broker_name} configuration"
  name           = "${local.broker_name}-configuration-${local.env}"
  engine_type    = "ActiveMQ"
  engine_version = local.engine_version

  data = var.mq_configuration_data
}

###########################
# Network Load Balancer
###########################
resource "aws_lb" "mq_nlb" {
  name                             = "${local.broker_name}-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  security_groups                  = [module.mq_sg.security_group_id]
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
}

resource "aws_cloudwatch_log_delivery_source" "mq_nlb_logging_source" {
  name         = "${local.broker_name}-nlb"
  log_type     = "NLB_ACCESS_LOGS"
  resource_arn = aws_lb.mq_nlb.arn
}

resource "aws_cloudwatch_log_delivery_destination" "mq_nlb_logging_destination" {
  name = "${local.broker_name}-nlb-logs"

  delivery_destination_configuration {
    destination_resource_arn = data.terraform_remote_state.s3.outputs.loadbalancer_bucket_sin_arn
  }
}

resource "aws_cloudwatch_log_delivery" "mq_nlb_logging" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.mq_nlb_logging_source.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.mq_nlb_logging_destination.arn

  s3_delivery_configuration {
    suffix_path                 = "${local.broker_name}-nlb-logs"
    enable_hive_compatible_path = true
  }
}

resource "aws_lb_target_group" "mq_nlb_target_group" {
  for_each = local.mq_ports

  name        = "${var.broker_prefix}-nlb-${each.value}"
  port        = each.value
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  stickiness {
    type    = "source_ip"
    enabled = false
  }
}

resource "aws_lb_listener" "mq_nlb_listener" {
  for_each = local.mq_ports

  load_balancer_arn = aws_lb.mq_nlb.arn
  port              = each.value
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.nlb_tls_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mq_nlb_target_group[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "mq_nlb_target_group_attachment" {
  for_each = {
    for pair in flatten([
      for port_key, port_val in local.mq_ports : [
        for idx in local.mq_target_indices : {
          key      = "${port_key}-${idx}"
          port     = port_val
          port_key = port_key
          idx      = idx
        }
      ]
    ]) : pair.key => pair
  }

  target_group_arn = aws_lb_target_group.mq_nlb_target_group[each.value.port_key].arn
  target_id        = aws_mq_broker.mq.instances[each.value.idx].ip_address
  port             = each.value.port
}

###########################
# Security Group
###########################
module "mq_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name                     = "${local.broker_name}-sg"
  description              = "Default Security group for ${local.broker_name} MQ Broker"
  vpc_id                   = local.vpc_id
  ingress_with_cidr_blocks = concat(local.default_ingress_with_cidr_blocks, var.additional_ingress_with_cidr_blocks)
  egress_rules             = ["all-all"]
  egress_cidr_blocks       = ["0.0.0.0/0"]
}

###########################
# Secrets Manager
###########################
resource "random_password" "mq_admin" {
  length           = 15
  special          = true
  min_special      = 1
  min_upper        = 1
  override_special = "!@#$%^&*"
}

resource "aws_secretsmanager_secret" "mq_admin" {
  name = "mq/${local.env}/${local.broker_name}/admin"
}

resource "aws_secretsmanager_secret_version" "mq_admin" {
  secret_id = aws_secretsmanager_secret.mq_admin.id
  secret_string = jsonencode({
    username = "mq_admin"
    password = random_password.mq_admin.result
  })
}

###########################
# MQ Users
###########################
resource "random_password" "mq_user" {
  for_each = { for user in var.mq_users : user.username => user }

  length           = 15
  special          = true
  min_special      = 1
  min_upper        = 1
  override_special = "!@#$%^&*"
}

resource "aws_secretsmanager_secret" "mq_user" {
  for_each = { for user in var.mq_users : user.username => user }

  name = "mq/${local.env}/${local.broker_name}/${each.key}"
}

resource "aws_secretsmanager_secret_version" "mq_user" {
  for_each = { for user in var.mq_users : user.username => user }

  secret_id = aws_secretsmanager_secret.mq_user[each.key].id
  secret_string = jsonencode({
    username = each.key
    password = random_password.mq_user[each.key].result
  })
}
