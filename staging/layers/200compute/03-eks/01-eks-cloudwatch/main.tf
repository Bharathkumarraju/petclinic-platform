
# module "eks_cloudwatch_log_groups" {
#   source   = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/cloudwatch-logs"
#   for_each = { for k, v in local.eks_cloudwatch_log_groups : k => v }

#   cloudwatch_log_name            = each.value.cloudwatch_log
#   cloudwatch_log_group_tags      = each.value.log_tags
#   cloudwatch_logs_encryption_key = each.value.cloudwatch_logs_encrypt_key
#   cloudwatch_logs_retention_days = each.value.retention_in_days
# }
