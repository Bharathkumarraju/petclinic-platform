############################################################
#  Required Pod Identity permissions for the cluster
############################################################

module "aws_ebs_csi_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  #version = "1.5.0"
  version = "1.12.1"

  name = "aws-ebs-csi"

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "ebs-csi-controller-sa"
  }

  associations = {
    cluster-one = {
      cluster_name = local.eks_cluster_name
    }
  }

  attach_aws_ebs_csi_policy = true
  aws_ebs_csi_kms_arns      = ["${local.ebs_kms_arn}"]

  tags = local.aws_ebs_csi_pod_identity_tags
}


module "aws_lb_controller_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  #version = "1.5.0"
  version = "1.12.1"

  name = "aws-lbc"

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "aws-load-balancer-controller"
  }

  associations = {
    cluster-one = {
      cluster_name = local.eks_cluster_name
    }
  }

  attach_aws_lb_controller_policy = true

  tags = local.aws_lb_controller_pod_identity_tags
}

module "external_secrets_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  #version = "1.5.0"
  version = "1.12.1"

  name = "external-secrets"

  # Pod Identity Associations
  association_defaults = {
    namespace       = "external-secrets"
    service_account = "external-secrets-operator"
  }

  associations = {
    cluster-one = {
      cluster_name = local.eks_cluster_name
    }
  }

  tags = local.external_secrets_operator_pod_identity_tags
}

resource "aws_spot_datafeed_subscription" "default" {
  bucket = local.spot_datafeed_bucket_id
  prefix = "spot_datafeed"
}

module "external_dns_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  #version = "1.5.0"
  version = "1.12.1"
  name    = "external-dns"

  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "external-dns-sa"
  }

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]

  associations = {
    cluster-one = {
      cluster_name = local.eks_cluster_name
    }
  }

  tags = local.externaldns_pod_identity_tags
}

module "guardduty_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  # version = "1.5.0"
  version = "1.12.1"

  name = "guardduty"

  # Pod Identity Associations
  association_defaults = {
    namespace       = "amazon-guardduty"
    service_account = "aws-guardduty-agent"
  }


  associations = {
    cluster-one = {
      cluster_name = local.eks_cluster_name
    }
  }

  tags = local.guardduty_pod_identity_tags
}

# Create the custom IAM policy using the rendered template
resource "aws_iam_policy" "guardduty_policy" {
  name        = "GuarddutyPolicy"
  description = "Policy for Guardduty agent"

  policy = local.guardduty_custom_policy

  tags = local.guardduty_pod_identity_tags
}

# Attach the custom policy to the IAM role created by the eks-pod-identity module
resource "aws_iam_role_policy_attachment" "attach_guardduty_policy" {
  depends_on = [module.guardduty_pod_identity]

  role       = module.guardduty_pod_identity.iam_role_name
  policy_arn = aws_iam_policy.guardduty_policy.arn
}

module "teleportcloud_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  # version = "1.5.0"
  version = "1.12.1"

  name = "teleportcloud-kube-agent"

  # Pod Identity Associations
  association_defaults = {
    namespace       = "teleportcloud-kube-agent"
    service_account = "teleportcloud-kube-agent"
  }


  associations = {
    cluster-one = {
      cluster_name = local.eks_cluster_name
    }
  }

  tags = local.teleportcloud_pod_identity_tags
}

# Create the custom IAM policy using the rendered template
resource "aws_iam_policy" "teleportcloud_policy" {
  name        = "TeleportCloudPolicy"
  description = "Policy for TeleportCloud k8s agent"

  policy = local.teleportcloud_custom_policy

  tags = local.teleportcloud_pod_identity_tags
}

# Attach the custom policy to the IAM role created by the eks-pod-identity module
resource "aws_iam_role_policy_attachment" "attach_teleportcloud_policy" {
  depends_on = [module.teleportcloud_pod_identity]

  role       = module.teleportcloud_pod_identity.iam_role_name
  policy_arn = aws_iam_policy.teleportcloud_policy.arn
}
