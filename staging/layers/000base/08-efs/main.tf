# module "cronicle_efs_sin" {
#   source  = "terraform-aws-modules/efs/aws"
#   version = ">= 1.3.1"
#
#   # File system
#   name                  = lookup(local.efs_storage["cronicle_efs_sin"], "efs_name")
#   creation_token        = lookup(local.efs_storage["cronicle_efs_sin"], "efs_name")
#   kms_key_arn           = local.common_kms_key_ec2_ebs_id
#   encrypted             = true
#   create_security_group = false
#   enable_backup_policy  = true
#   performance_mode      = "generalPurpose"
#   throughput_mode       = "elastic"
#   lifecycle_policy      = lookup(local.efs_storage["cronicle_efs_sin"], "lifecycle_policy")
#   # File system policy
#   attach_policy     = true
#   policy_statements = lookup(local.efs_storage["cronicle_efs_sin"], "policy_statements")
#   tags              = lookup(local.efs_storage["cronicle_efs_sin"], "efs_tags")
# }
#
#
# resource "aws_efs_mount_target" "cronicle_efs_mnt_sin" {
#   count           = length(local.main_vpc_private_subnet_sin)
#   file_system_id  = module.cronicle_efs_sin.id
#   subnet_id       = local.main_vpc_private_subnet_sin[count.index]
#   security_groups = [local.efs_cronicle_id_sin]
# }
