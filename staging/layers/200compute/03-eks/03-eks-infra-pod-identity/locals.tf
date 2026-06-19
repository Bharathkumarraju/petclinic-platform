locals {

  # Get all required KMS Keys from remote state
  ebs_kms_arn                  = data.terraform_remote_state.ebs-kms-keys.outputs.kms_key_ec2_ebs_sin.arn
  cloudwatch_log_group_kms_arn = data.terraform_remote_state.kms_cloudwatch_logs.outputs.kms_key_cloudwatch_logs_sin.arn
  secrets_manager_kms_arn      = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
  kms_secrets_manager_arn      = data.terraform_remote_state.kms_secrets_manager.outputs.kms_key_secrets_mgr_sin.arn

  spot_datafeed_bucket_id = data.terraform_remote_state.bucket.outputs.spot_datafeed_bucket_sin

  # Secrets Manager ARN
  secrets_manager_arns = [
    "arn:aws:secretsmanager:${local.vpc_region}:${local.account_id}:secret:${local.env}/*"
  ]

  # EKS Cluster parameters from remote state
  eks_cluster_name           = data.terraform_remote_state.eks_base.outputs.eks_cluster.cluster_name
  eks_cluster_version        = data.terraform_remote_state.eks_base.outputs.eks_cluster.cluster_version
  eks_cluster_endpoint       = data.terraform_remote_state.eks_base.outputs.eks_cluster.cluster_endpoint
  eks_cluster_ca_certificate = data.terraform_remote_state.eks_base.outputs.eks_cluster.cluster_certificate_authority_data
  eks_oidc_provider          = data.terraform_remote_state.eks_base.outputs.eks_cluster.oidc_provider
  eks_oicd_provider_arn      = data.terraform_remote_state.eks_base.outputs.eks_cluster.oidc_provider_arn


  # Get all network objects from remote state
  # vpc_id              = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  vpc_region = "ap-southeast-1"
  # eks_private_subnets = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  # eks_security_group  = data.terraform_remote_state.network-layer-1.outputs.eks_cluster_sg_id_sin


  # Tags for pod identity
  # EBS CSI Pod Identity Tags
  aws_ebs_csi_pod_identity_tags = {
    "Name"         = "aws-ebs-csi"
    "purpose"      = "EBS CSI Pod Identity"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # Loadbalancer Controller Pod Identity Tags
  aws_lb_controller_pod_identity_tags = {
    "Name"         = "aws_lb_controller"
    "purpose"      = "Load Balancer controller Pod Identity"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # External Secrets Operator Pod Identity Tags
  external_secrets_operator_pod_identity_tags = {
    "Name"         = "eso"
    "purpose"      = "External Secrets Operator Pod Identity"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # ExternalDNS Operator Pod Identity Tags
  externaldns_pod_identity_tags = {
    "Name"         = "External DNS"
    "purpose"      = "External DNS Pod Identity"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # Guardduty Pod Identity Tags
  guardduty_pod_identity_tags = {
    "Name"         = "Guardduty Agent"
    "purpose"      = "Guardduty Agent Pod Identity"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # TeleportCloud Pod Identity Tags
  teleportcloud_pod_identity_tags = {
    "Name"         = "TeleportCloud Agent"
    "purpose"      = "TeleportCloud Agent Pod Identity"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # Render the policy template
  cloudwatch_custom_policy = templatefile(
    "${path.module}/templates/cloudwatch_custom_policy.tpl",
    {
      account_id = local.account_id
      region     = local.vpc_region
      #    log_group_name = "/aws/eks/${local.env}/pod/staging-frontend-md"   commented for now
      kms_key_arn = data.terraform_remote_state.kms_cloudwatch_logs.outputs.kms_key_cloudwatch_logs_sin.arn
  })

  # Guardduty
  guardduty_custom_policy = templatefile(
    "${path.module}/templates/guardduty_custom_policy.tpl",
    {
      account_id = local.account_id
      region     = local.vpc_region
    }
  )

  # TeleportCloud
  teleportcloud_custom_policy = templatefile(
    "${path.module}/templates/teleportcloud_custom_policy.tpl",
    {
      account_id              = local.account_id
      kms_secrets_manager_arn = local.kms_secrets_manager_arn
    }
  )

}
