# Elastic Token passed from AWS SSM
variable "staging_elastic_enrollment_token" {
  sensitive = true
}

variable "staging_elastic_apm_enrollment_token" {
  sensitive = true
}

variable "staging_elastic_eks_fleet_enrollment_token" {
  sensitive = true
}

variable "github_eks_base_token" {
  sensitive = true
}

variable "eks_staging_elastic_apm_key" {
  sensitive = true
}

locals {
  aws_account = data.aws_caller_identity.current.id

  # Get all required KMS Keys from remote state
  # ebs_kms_arn                  = data.terraform_remote_state.ebs-kms-keys.outputs.kms_key_ec2_ebs_sin.arn
  # cloudwatch_log_group_kms_arn = data.terraform_remote_state.kms_cloudwatch_logs.outputs.kms_key_cloudwatch_logs_sin.arn
  # secrets_manager_kms_arn      = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn

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

  # Elastic enrollment Token
  fleet_enrollment_token = var.staging_elastic_eks_fleet_enrollment_token
  fleet_url              = "https://ce8efea464849a22a8161a6c3a06e2e3.fleet.vpce.ap-southeast-1.aws.elastic-cloud.com:443"
  # elastic_agent_version  = "8.18.0"
  elastic_agent_version        = "9.0.4"
  elastic_agent_tags           = "staging-eks"
  elastic_helm_chart_version   = "2.0.2"
  github_eks_base_token        = var.github_eks_base_token
  elastic_apm_enrollment_token = var.staging_elastic_apm_enrollment_token
  elastic_apm_endpoint         = "apm.staging.abex.int:8200"
  elastic-apm-key              = var.eks_staging_elastic_apm_key
  apm-target-namespaces        = ["clarity-staging", "mdapi-staging", "tradingview-staging", "edge-staging", "eprime-staging"]
  apm-application-packages     = ["com.baymarkets", "no.oc"]
  elastic-apm-image            = "120430566909.dkr.ecr.ap-southeast-1.amazonaws.com/elastic/tracing/apm-attacher"
  elastic-apm-image-tag        = "v1.0.5"

  # EKS Cluster tags
  eks_cluster_tags = {
    "Name"         = "${local.eks_cluster_name}"
    "purpose"      = "Cluster to host containers"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }
  fluentbit_sa        = "fluentbit-sa"
  fluentbit_s3_bucket = "abex-app-compliance-bucket-staging-sin"
  s3_kms_key_arn      = data.terraform_remote_state.kms-s3-logs-sin.outputs.kms_key_s3_sin.arn
  s3_kms_key_id       = data.terraform_remote_state.kms-s3-logs-sin.outputs.kms_key_s3_sin.id

  # Set Ingress target type
  default_target_type = "ip"

  # Teleport database endpoints from RDS proxy outputs
  # All endpoints are dynamically sourced from terraform remote state
  teleport_databases = [
    # Exchange DB - Read-Write (default proxy endpoint)
    {
      name        = "exchangedb-aps1-proxy-${local.env}-k8s"
      description = "Static AWS RDS ExchangeDB Proxy endpoint"
      protocol    = "mysql"
      uri         = "${data.terraform_remote_state.exchangedb.outputs.claradb_proxy_endpoints}:3306"
      labels = {
        env           = local.env
        name          = "exchange-aps1-proxy-${local.env}-rw-endpoint"
        endpoint-type = "READ_WRITE"
      }
    },
    # Exchange DB - Read-Only (custom endpoint from db_proxy_endpoints)
    {
      name        = "exchangedb-aps1-proxy-${local.env}-r-endpoint-k8s"
      description = "Static AWS RDS ExchangeDB Readonly Proxy endpoint"
      protocol    = "mysql"
      uri         = "${data.terraform_remote_state.exchangedb.outputs.claradb_proxy_custom_endpoints["read_only"].endpoint}:3306"
      labels = {
        env           = local.env
        name          = "exchange-aps1-proxy-${local.env}-r-endpoint"
        endpoint-type = "READ_ONLY"
      }
    },
    # Risk DB - Read-Write (default proxy endpoint)
    {
      name        = "riskdb-aps1-proxy-${local.env}-k8s"
      description = "Static AWS RDS RiskDB Proxy endpoint"
      protocol    = "mysql"
      uri         = "${data.terraform_remote_state.riskdb.outputs.riskdb_proxy_endpoints}:3306"
      labels = {
        env           = local.env
        name          = "riskdb-aps1-proxy-${local.env}-rw-endpoint"
        endpoint-type = "READ_WRITE"
      }
    },
    # Risk DB - Read-Only (custom endpoint from db_proxy_endpoints)
    {
      name        = "riskdb-aps1-proxy-${local.env}-r-endpoint-k8s"
      description = "Static AWS RDS RiskDB Readonly Proxy endpoint"
      protocol    = "mysql"
      uri         = "${data.terraform_remote_state.riskdb.outputs.riskdb_proxy_custom_endpoints["read_only"].endpoint}:3306"
      labels = {
        env           = local.env
        name          = "riskdb-aps1-proxy-${local.env}-r-endpoint"
        endpoint-type = "READ_ONLY"
      }
    }
  ]
}

