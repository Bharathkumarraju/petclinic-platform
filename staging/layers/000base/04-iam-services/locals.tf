

locals {
  # region    = "sin"
  kms_secrets_manager_arn   = data.terraform_remote_state.kms_secrets_manager.outputs.kms_key_secrets_mgr_sin.arn
  kms_secrets_manager_alias = "alias/kms-secrets-manager-staging-sin"
  # S3 KMS key
  s3_kms_arn                = data.terraform_remote_state.s3_kms.outputs.kms_key_s3_sin.arn
  service_prefix            = "svc"
  common_policies_path      = "common-policies"
  common_access_policy_file = "access-policy.json"
  common_action_policy_file = "action-policy.json"


  # bucketname
  ses_bucket_name        = "abex-ses-bucket-staging-sin"
  cloudwatch_bucket_name = "abex-cloudwatch-bucket-staging-sin"



  service_role_name = {
    vpc_flow_log                = "${local.service_prefix}-vpc-flow-log"
    lambda_s3                   = "${local.service_prefix}-lambda-s3"
    ec2_default                 = "${local.service_prefix}-ec2-default"
    rds-enhanced-monitoring     = "${local.service_prefix}-rds-monitoring"
    ec2_teleport_db             = "${local.service_prefix}-ec2-teleport-db"
    ec2_cronicle                = "${local.service_prefix}-ec2-cronicle"
    ec2_elastic_agent           = "${local.service_prefix}-ec2-elastic-agent"
    cloudwatch_s3               = "${local.service_prefix}-cloudwatch-s3"
    aws_backup                  = "${local.service_prefix}-aws-backup"
    rds_proxy_connect           = "${local.service_prefix}-rds-proxy-connect"
    github-actions              = "${local.service_prefix}-github-actions"
    ses_logs_ses_firehose       = "${local.service_prefix}-ses-logs-ses-firehose"
    ses_logs_firehose_s3        = "${local.service_prefix}-ses-logs-firehose-s3"
    exberry-uat-stag            = "${local.service_prefix}-exberry-uat-stag"
    exberry-clara-6-6           = "${local.service_prefix}-exberry-clara-6-6"
    dms-vpc-role                = "dms-vpc-role"
    cloudwatch_logs_firehose    = "${local.service_prefix}-cloudwatch-logs-firehose"
    cloudwatch_logs_firehose_s3 = "${local.service_prefix}-cloudwatch-logs-firehose-s3"
    # network-eks-access          = "${local.service_prefix}-network-eks-access"
    network-dev-eks-access = "${local.service_prefix}-network-dev-eks-access"
  }

  service_role = {
    vpc_flow_log_sin = {
      role_name                      = "${local.service_role_name["vpc_flow_log"]}-${local.env}-sin"
      role_description               = "Service Role for VPC to write to Cloudwatch Logs"
      assume_role_policy             = "${file("${local.common_policies_path}/vpc-flow-log/${local.common_access_policy_file}")}"
      action_role_policy_name        = "${local.service_role_name["vpc_flow_log"]}-policy-sin"
      action_role_policy_description = "Policy to allow write to Cloudwatch Logs"
      action_role_policy             = "${file("${local.common_policies_path}/vpc-flow-log/${local.common_action_policy_file}")}"
      role_tags = {
        env          = local.env
        purpose      = "Allow VPC Flow Log to write to Cloudwatch Logs"
        map-migrated = "mig46499"
      }
    }
    lambda_s3_sin = {
      role_name                      = "${local.service_role_name["lambda_s3"]}-${local.env}-sin"
      role_description               = "Service Role for Lambda to access S3 bucket to read code"
      assume_role_policy             = "${file("policies/lambda-s3/lambda-s3-access-policy-sin.json")}"
      action_role_policy_name        = "${local.service_role_name["lambda_s3"]}-policy-sin"
      action_role_policy_description = "Policy to allow Lambda to access S3 bucket to read code"
      action_role_policy             = "${file("policies/lambda-s3/lambda-s3-action-policy-sin.json")}"
      role_tags = {
        env          = local.env
        purpose      = "Allow Lambda to access S3 bucket to read code"
        map-migrated = "mig46499"
      }
    }
    # Supports multiple permission policy in the action policy list
    ec2_default_sin = {
      role_name                      = "${local.service_role_name["ec2_default"]}-${local.env}-sin"
      role_description               = "Service Role for EC2 to be managed by SSM"
      assume_role_policy             = "${file("${local.common_policies_path}/ec2-default/${local.common_access_policy_file}")}"
      action_role_policy_name        = "${local.service_role_name["ec2_default"]}-policy-sin"
      action_role_policy_description = "Policy to allow EC2 default perms"
      action_role_policy             = "${file("policies/ec2-default/ec2-default-action-policy-sin.json")}"
      action_role_policy_list = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      ]
      instance_profile_name = "${local.service_role_name["ec2_default"]}"
      role_tags = {
        env          = local.env
        purpose      = "Allow EC2 to be managed by SSM"
        map-migrated = "mig46499"
      }
    }
    # network-eks-access = {
    #   role_name                      = "${local.service_role_name["network-eks-access"]}-${local.env}-sin"
    #   role_description               = "Service Role to assume from network eks to staging eks"
    #   assume_role_policy             = "${file("${local.common_policies_path}/network-eks-access/${local.common_access_policy_file}")}"
    #   action_role_policy_name        = "${local.service_role_name["network-eks-access"]}-policy-sin"
    #   action_role_policy_description = "Service Role to assume from network eks to staging eks"
    #   action_role_policy             = "${file("${local.common_policies_path}/network-eks-access/${local.common_action_policy_file}")}"
    #   role_tags = {
    #     env          = local.env
    #     purpose      = "assume role for cross EKS cluster access"
    #     map-migrated = "mig46499"
    #   }
    # }
    network-dev-eks-access = {
      role_name                      = "${local.service_role_name["network-dev-eks-access"]}-${local.env}-sin"
      role_description               = "Service Role to assume from network dev eks to staging eks"
      assume_role_policy             = "${file("${local.common_policies_path}/network-dev-eks-access/${local.common_access_policy_file}")}"
      action_role_policy_name        = "${local.service_role_name["network-dev-eks-access"]}-policy-sin"
      action_role_policy_description = "Service Role to assume from network dev eks to staging eks"
      action_role_policy             = "${file("${local.common_policies_path}/network-dev-eks-access/${local.common_action_policy_file}")}"
      role_tags = {
        env          = local.env
        purpose      = "assume role for cross EKS cluster access"
        map-migrated = "mig46499"
      }
    }
    rds_monitoring_sin = {
      role_name                      = "${local.service_role_name["rds-enhanced-monitoring"]}-${local.env}-sin"
      role_description               = "Service Role RDS enhanced monitoring"
      assume_role_policy             = "${file("policies/rds-monitoring/rds-monitoring-assume-policy.json")}"
      action_role_policy_name        = null
      action_role_policy             = null
      action_role_policy_description = "Service Role RDS enhanced monitoring"
      action_role_policy_list        = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
      role_tags = {
        env          = local.env
        purpose      = "enhanced RDS monitoring role"
        map-migrated = "mig46499"
      }
    }
    rds_proxy_connect_sin = {
      role_name                      = "${local.service_role_name["rds_proxy_connect"]}-${local.env}-sin"
      role_description               = "Service Role to connect to RDS Proxy"
      assume_role_policy             = "${file("policies/rds-proxy-connect/rds-proxy-connect-access-policy-sin.json")}"
      action_role_policy_name        = "${local.service_role_name["rds_proxy_connect"]}-policy-sin"
      action_role_policy_description = "Policy to connect to RDS Proxy"
      action_role_policy = templatefile("policies/rds-proxy-connect/rds-proxy-connect-action-policy-sin.json",
        {
          account_id              = local.account_id,
          kms_secrets_manager_arn = local.kms_secrets_manager_arn
      })
      role_tags = {
        env          = local.env
        purpose      = "RDS Proxy Connect Role"
        map-migrated = "mig46499"
      }
    }
    ec2_cronicle_sin = {
      role_name                      = "${local.service_role_name["ec2_cronicle"]}-${local.env}-sin"
      role_description               = "Service Role for Cronicle service"
      assume_role_policy             = "${file("${local.common_policies_path}/ec2-default/${local.common_access_policy_file}")}"
      action_role_policy_name        = "${local.service_role_name["ec2_cronicle"]}-policy-sin"
      action_role_policy_description = "Policy to run Cronicle services"
      action_role_policy             = "${file("policies/ec2-cronicle/ec2-cronicle-action-policy-sin.json")}"
      action_role_policy_list = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy",
      ]
      instance_profile_name = "${local.service_role_name["ec2_cronicle"]}"
      role_tags = {
        env          = local.env
        purpose      = "Cronicle services"
        map-migrated = "mig46499"
      }
    }
    ec2_elastic_agent = {
      role_name                      = "${local.service_role_name["ec2_elastic_agent"]}-${local.env}-sin"
      role_description               = "Service Role for EC2 Elastic Agent"
      assume_role_policy             = file("${local.common_policies_path}/ec2-default/${local.common_access_policy_file}")
      action_role_policy_name        = "${local.service_role_name["ec2_elastic_agent"]}-policy-sin"
      action_role_policy_description = "Policy to ingest logs and metrics for Elastic"
      action_role_policy = templatefile("policies/ec2-elastic-agent/ec2-elastic-agent-action-policy-sin.json",
        {
          account_id = local.account_id
          # TODO (6 May 26) to remove the hardcode
          secretsmanager_kms_key_arn  = local.kms_secrets_manager_arn
          enrollment_token_secret_arn = "arn:aws:secretsmanager:ap-southeast-1:993533333148:secret:elastic/abex-nonprod/aws-hXCrZo"
      })
      action_role_policy_list = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/AmazonInspector2ManagedCisPolicy"
      ]
      instance_profile_name = "${local.service_prefix}-ec2-elastic-agent"
      role_tags = {
        env          = local.env
        map-migrated = "mig46499"
        purpose      = "Allow EC2 to ingest logs and metrics from AWS for Elastic"
      }
    }

    cloudwatch_s3_sin = {
      role_name                      = "${local.service_role_name["cloudwatch_s3"]}-${local.env}-sin"
      role_description               = "Service Role for Cloudwatch Logs to access S3 bucket to archive logs"
      assume_role_policy             = "${file("policies/cloudwatch-logs-s3/cloudwatch-logs-s3-access-policy-sin.json")}"
      action_role_policy_name        = "${local.service_role_name["cloudwatch_s3"]}-policy-sin"
      action_role_policy_description = "Policy to allow Cloudwatch Logs to access S3 bucket to archive logs"
      action_role_policy             = "${file("policies/cloudwatch-logs-s3/cloudwatch-logs-s3-action-policy-sin.json")}"
      role_tags = {
        env          = local.env
        purpose      = "Allow Cloudwatch Logs to access S3 bucket to archive logs"
        map-migrated = "mig46499"
      }
    }
    aws_backup_sin = {
      role_name                      = "${local.service_role_name["aws_backup"]}-${local.env}-sin"
      role_description               = "Allow AWS Backup to access perform backup/restore operations"
      assume_role_policy             = "${file("${local.common_policies_path}/aws-backup-default/${local.common_access_policy_file}")}"
      action_role_policy_name        = null
      action_role_policy_description = "Allow AWS Backup to access perform backup/restore operations"
      action_role_policy_list = [
        "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
        "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
      ]
      role_tags = {
        env          = local.env
        purpose      = "Allow AWS Backup to access perform backup/restore operations"
        map-migrated = "mig46499"
      }
    }

    github_actions_sin = {
      role_name                      = "${local.service_role_name["github-actions"]}-${local.env}-sin"
      role_description               = "Service Role for Github Actions"
      assume_role_policy             = templatefile("policies/github-actions/github-actions-access-policy-sin.json", { env = local.env, account_id = local.account_id })
      action_role_policy_name        = "${local.service_role_name["github-actions"]}-policy-sin"
      action_role_policy_description = "Policy to run Github Actions for K8 Deployments"
      action_role_policy             = templatefile("policies/github-actions/github-actions-action-policy-sin.json", { env = local.env, account_id = local.account_id })
      role_tags = {
        env          = local.env
        purpose      = "github-actions-for-k8-deployment"
        map-migrated = "mig46499"
      }
    }
    ses_logs_ses_firehose = {
      role_name        = "${local.service_role_name["ses_logs_ses_firehose"]}-${local.env}-sin"
      role_description = "Service Role to connect from SES to Kinesis Firehose"
      assume_role_policy = templatefile("policies/ses-logs-ses-firehose/ses-logs-ses-firehose-access-policy-sin.json", {
        account_id = local.account_id
      })
      action_role_policy_name        = "${local.service_role_name["ses_logs_ses_firehose"]}-policy-sin"
      action_role_policy_description = "Policy to connect from SES to Kinesis Firehose"
      action_role_policy = templatefile("policies/ses-logs-ses-firehose/ses-logs-ses-firehose-action-policy-sin.json", {
        account_id = local.account_id
      })
      role_tags = {
        env          = local.env
        purpose      = "SES to Kinesis Firehose Role"
        map-migrated = "mig46499"
      }
    }
    ses_logs_firehose_s3 = {
      role_name                      = "${local.service_role_name["ses_logs_firehose_s3"]}-${local.env}-sin"
      role_description               = "Service Role to connect from Kinesis Firehose to S3"
      assume_role_policy             = "${file("policies/ses-logs-firehose-s3/ses-logs-firehose-s3-access-policy-sin.json")}"
      action_role_policy_name        = "${local.service_role_name["ses_logs_firehose_s3"]}-policy-sin"
      action_role_policy_description = "Policy to connect from Kinesis Firehose to S3"
      action_role_policy = templatefile("policies/ses-logs-firehose-s3/ses-logs-firehose-s3-action-policy-sin.json", {
        bucket_name = local.ses_bucket_name
      })
      role_tags = {
        env          = local.env
        purpose      = "Kinesis Firehose to S3 Role"
        map-migrated = "mig46499"
      }
    }

    dms-vpc-role_sin = {
      role_name                      = "${local.service_role_name["dms-vpc-role"]}"
      role_description               = "DMS - VPC"
      assume_role_policy             = templatefile("policies/dms-rds/dms-vpc-role-trust-policy.json", {})
      action_role_policy_name        = "${local.service_role_name["dms-vpc-role"]}-policy-sin"
      action_role_policy_description = "Policy to enable DMS Access"
      action_role_policy             = templatefile("policies/dms-rds/dms-vpc-role-action-policy.json", {})
      role_tags = {
        env          = local.env
        purpose      = "Allow DMS Access"
        map-migrated = "mig46499"
      }

    }

    cloudwatch_logs_firehose = {
      role_name        = "${local.service_role_name["cloudwatch_logs_firehose"]}-${local.env}-sin"
      role_description = "Service Role to connect from Cloudwatch Logs to Kinesis Firehose"
      assume_role_policy = templatefile("policies/cloudwatch-logs-firehose/cloudwatch-logs-firehose-access-policy-sin.json", {
        account_id = local.account_id
      })
      action_role_policy_name        = "${local.service_role_name["cloudwatch_logs_firehose"]}-policy-sin"
      action_role_policy_description = "Policy to connect from Cloudwatch Logs to Kinesis Firehose"
      action_role_policy = templatefile("policies/cloudwatch-logs-firehose/cloudwatch-logs-firehose-action-policy-sin.json", {
        account_id = local.account_id,
        kms_key    = local.s3_kms_arn
      })
      role_tags = {
        env          = local.env
        purpose      = "Cloudwatch Logs to Kinesis Firehose Role"
        map-migrated = "mig46499"
      }
    }
    cloudwatch_logs_firehose_s3 = {
      role_name                      = "${local.service_role_name["cloudwatch_logs_firehose_s3"]}-${local.env}-sin"
      role_description               = "Service Role to connect from Kinesis Firehose to S3"
      assume_role_policy             = "${file("policies/cloudwatch-logs-firehose-s3/cloudwatch-logs-firehose-s3-access-policy-sin.json")}"
      action_role_policy_name        = "${local.service_role_name["cloudwatch_logs_firehose_s3"]}-policy-sin"
      action_role_policy_description = "Policy to connect from Kinesis Firehose to S3"
      action_role_policy = templatefile("policies/cloudwatch-logs-firehose-s3/cloudwatch-logs-firehose-s3-action-policy-sin.json", {
        bucket_name = local.cloudwatch_bucket_name,
        kms_key     = local.s3_kms_arn
      })
      role_tags = {
        env          = local.env
        purpose      = "Kinesis Firehose to S3 Role"
        map-migrated = "mig46499"
      }
    }
  }
}

