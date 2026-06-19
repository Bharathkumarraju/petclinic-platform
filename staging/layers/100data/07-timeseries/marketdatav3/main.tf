# # Creating a module is not possible at this point due to a bug in the provider. Once the bug is fixed, we can move this resource into the module.
# # The HashiCorp team is currently working on a fix (PR #45782) that defers this validation until after variable interpolation.
# resource "aws_timestreaminfluxdb_db_cluster" "this" {
#   name                          = "${local.influxdb_name}-aps1-staging"
#   db_instance_type              = local.influxdb_instance_type
#   db_parameter_group_identifier = "InfluxDBV3Core" # multi-az = false

#   # Network Configuration
#   vpc_subnet_ids         = local.vpc_subnet_ids
#   vpc_security_group_ids = local.vpc_security_group_ids
#   publicly_accessible    = false
#   network_type           = "IPV4"
#   port                   = local.influxdb_port

#   # Log Delivery
#   log_delivery_configuration {
#     s3_configuration {
#       bucket_name = local.s3_log_bucket_name
#       enabled     = true
#     }
#   }
# }

# module "influxdb_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "5.3.1"

#   name                     = "${local.influxdb_name}-sg"
#   description              = "Security Group for the ${local.influxdb_name} database"
#   vpc_id                   = local.vpc_id
#   revoke_rules_on_delete   = true
#   ingress_with_cidr_blocks = concat(local.default_ingress_with_cidr_blocks, local.additional_ingress_with_cidr_blocks)
#   egress_with_cidr_blocks  = local.default_egress_with_cidr_blocks
# }