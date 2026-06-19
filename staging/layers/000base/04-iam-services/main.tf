module "vpc_flow_log_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["vpc_flow_log_sin"], "role_name")
  src_role_description          = lookup(local.service_role["vpc_flow_log_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["vpc_flow_log_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["vpc_flow_log_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["vpc_flow_log_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["vpc_flow_log_sin"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["vpc_flow_log_sin"], "role_tags")
}

module "lambda_s3_log_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["lambda_s3_sin"], "role_name")
  src_role_description          = lookup(local.service_role["lambda_s3_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["lambda_s3_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["lambda_s3_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["lambda_s3_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["lambda_s3_sin"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["lambda_s3_sin"], "role_tags")
}

module "ec2_default_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["ec2_default_sin"], "role_name")
  src_role_description          = lookup(local.service_role["ec2_default_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["ec2_default_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["ec2_default_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["ec2_default_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["ec2_default_sin"], "action_role_policy")
  src_predefined_policy_list    = lookup(local.service_role["ec2_default_sin"], "action_role_policy_list")
  src_inst_profile_name         = lookup(local.service_role["ec2_default_sin"], "instance_profile_name")
  src_role_tags                 = lookup(local.service_role["ec2_default_sin"], "role_tags")
}

module "rds_enhanced_monitoring_log_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["rds_monitoring_sin"], "role_name")
  src_role_description          = lookup(local.service_role["rds_monitoring_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["rds_monitoring_sin"], "assume_role_policy")
  src_role_tags                 = lookup(local.service_role["rds_monitoring_sin"], "role_tags")
  src_predefined_policy_list    = lookup(local.service_role["rds_monitoring_sin"], "action_role_policy_list")
  src_action_policy_description = lookup(local.service_role["rds_monitoring_sin"], "action_role_policy_description")
}

module "ec2_cronicle_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["ec2_cronicle_sin"], "role_name")
  src_role_description          = lookup(local.service_role["ec2_cronicle_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["ec2_cronicle_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["ec2_cronicle_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["ec2_cronicle_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["ec2_cronicle_sin"], "action_role_policy")
  src_predefined_policy_list    = lookup(local.service_role["ec2_cronicle_sin"], "action_role_policy_list")
  src_inst_profile_name         = lookup(local.service_role["ec2_cronicle_sin"], "instance_profile_name")
  src_role_tags                 = lookup(local.service_role["ec2_cronicle_sin"], "role_tags")
}

module "ec2_elastic_agent_role_sin" {
  source                        = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"
  src_role_name                 = lookup(local.service_role["ec2_elastic_agent"], "role_name")
  src_role_description          = lookup(local.service_role["ec2_elastic_agent"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["ec2_elastic_agent"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["ec2_elastic_agent"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["ec2_elastic_agent"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["ec2_elastic_agent"], "action_role_policy")
  src_predefined_policy_list    = lookup(local.service_role["ec2_elastic_agent"], "action_role_policy_list")
  src_inst_profile_name         = lookup(local.service_role["ec2_elastic_agent"], "instance_profile_name")
  src_role_tags                 = lookup(local.service_role["ec2_elastic_agent"], "role_tags")
}

module "cloudwatch_s3_log_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["cloudwatch_s3_sin"], "role_name")
  src_role_description          = lookup(local.service_role["cloudwatch_s3_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["cloudwatch_s3_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["cloudwatch_s3_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["cloudwatch_s3_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["cloudwatch_s3_sin"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["cloudwatch_s3_sin"], "role_tags")
}
module "aws_backup_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["aws_backup_sin"], "role_name")
  src_role_description          = lookup(local.service_role["aws_backup_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["aws_backup_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["aws_backup_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["aws_backup_sin"], "action_role_policy_description")
  src_predefined_policy_list    = lookup(local.service_role["aws_backup_sin"], "action_role_policy_list")
  src_role_tags                 = lookup(local.service_role["aws_backup_sin"], "role_tags")
}
module "rds_proxy_connect_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["rds_proxy_connect_sin"], "role_name")
  src_role_description          = lookup(local.service_role["rds_proxy_connect_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["rds_proxy_connect_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["rds_proxy_connect_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["rds_proxy_connect_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["rds_proxy_connect_sin"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["rds_proxy_connect_sin"], "role_tags")
}

module "github_actions_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["github_actions_sin"], "role_name")
  src_role_description          = lookup(local.service_role["github_actions_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["github_actions_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["github_actions_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["github_actions_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["github_actions_sin"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["github_actions_sin"], "role_tags")
}

module "ses_logs_ses_firehose" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["ses_logs_ses_firehose"], "role_name")
  src_role_description          = lookup(local.service_role["ses_logs_ses_firehose"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["ses_logs_ses_firehose"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["ses_logs_ses_firehose"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["ses_logs_ses_firehose"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["ses_logs_ses_firehose"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["ses_logs_ses_firehose"], "role_tags")
}

module "ses_logs_firehose_s3" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["ses_logs_firehose_s3"], "role_name")
  src_role_description          = lookup(local.service_role["ses_logs_firehose_s3"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["ses_logs_firehose_s3"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["ses_logs_firehose_s3"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["ses_logs_firehose_s3"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["ses_logs_firehose_s3"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["ses_logs_firehose_s3"], "role_tags")
}

module "dms-vpc-role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["dms-vpc-role_sin"], "role_name")
  src_role_description          = lookup(local.service_role["dms-vpc-role_sin"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["dms-vpc-role_sin"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["dms-vpc-role_sin"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["dms-vpc-role_sin"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["dms-vpc-role_sin"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["dms-vpc-role_sin"], "role_tags")
}

module "cloudwatch_logs_firehose" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["cloudwatch_logs_firehose"], "role_name")
  src_role_description          = lookup(local.service_role["cloudwatch_logs_firehose"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["cloudwatch_logs_firehose"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["cloudwatch_logs_firehose"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["cloudwatch_logs_firehose"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["cloudwatch_logs_firehose"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["cloudwatch_logs_firehose"], "role_tags")
}

module "cloudwatch_logs_firehose_s3" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "role_name")
  src_role_description          = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["cloudwatch_logs_firehose_s3"], "role_tags")
}


# module "network_eks_access_role_sin" {
#   source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

#   src_role_name                 = lookup(local.service_role["network-eks-access"], "role_name")
#   src_role_description          = lookup(local.service_role["network-eks-access"], "role_description")
#   src_assume_role_policy        = lookup(local.service_role["network-eks-access"], "assume_role_policy")
#   src_action_policy_name        = lookup(local.service_role["network-eks-access"], "action_role_policy_name")
#   src_action_policy_description = lookup(local.service_role["network-eks-access"], "action_role_policy_description")
#   src_action_policy             = lookup(local.service_role["network-eks-access"], "action_role_policy")
#   src_role_tags                 = lookup(local.service_role["network-eks-access"], "role_tags")
# }

module "network_dev_eks_access_role_sin" {
  source = "git@github.com:abaxxsingapore/abex-aws-tf-modules.git//modules/iam-services"

  src_role_name                 = lookup(local.service_role["network-dev-eks-access"], "role_name")
  src_role_description          = lookup(local.service_role["network-dev-eks-access"], "role_description")
  src_assume_role_policy        = lookup(local.service_role["network-dev-eks-access"], "assume_role_policy")
  src_action_policy_name        = lookup(local.service_role["network-dev-eks-access"], "action_role_policy_name")
  src_action_policy_description = lookup(local.service_role["network-dev-eks-access"], "action_role_policy_description")
  src_action_policy             = lookup(local.service_role["network-dev-eks-access"], "action_role_policy")
  src_role_tags                 = lookup(local.service_role["network-dev-eks-access"], "role_tags")
}
