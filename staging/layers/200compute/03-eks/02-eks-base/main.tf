# Fetch Bottlerocket AMI Release Version Dynamically
data "aws_ssm_parameters_by_path" "bottlerocket" {
  path      = "/aws/service/bottlerocket/aws-k8s-${local.cluster_version}/x86_64/"
  recursive = true
}

############################################################
#  Required IAM permissions for the cluster
############################################################

# CloudWatch permissions for the cluster for the EKS pods to directly log to cloudwatch.


resource "aws_iam_policy" "node_cloudwatch_access" {
  name = replace("${local.region_prefix}-${local.env}-node-cloudwatch-access", ".", "-")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# AWS Guardduty agent access

resource "aws_iam_policy" "custom_guardduty_access" {
  name = "${local.env}-guardduty-agent-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AmazonGuardDutyFullAccessSid1",
        "Effect" : "Allow",
        "Action" : "guardduty:*",
        "Resource" : "*"
      },
      {
        "Sid" : "CreateServiceLinkedRoleSid1",
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : [
              "guardduty.amazonaws.com",
              "malware-protection.guardduty.amazonaws.com"
            ]
          }
        }
      },
      {
        "Sid" : "ActionsForOrganizationsSid1",
        "Effect" : "Allow",
        "Action" : [
          "organizations:EnableAWSServiceAccess",
          "organizations:RegisterDelegatedAdministrator",
          "organizations:ListDelegatedAdministrators",
          "organizations:ListAWSServiceAccessForOrganization",
          "organizations:DescribeOrganizationalUnit",
          "organizations:DescribeAccount",
          "organizations:DescribeOrganization",
          "organizations:ListAccounts"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "IamGetRoleSid1",
        "Effect" : "Allow",
        "Action" : "iam:GetRole",
        "Resource" : "arn:aws:iam::*:role/*AWSServiceRoleForAmazonGuardDutyMalwareProtection"
      },
      {
        "Sid" : "AllowPassRoleToMalwareProtectionPlan",
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : "arn:aws:iam::*:role/*",
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : "malware-protection-plan.guardduty.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Grants AWS-NW pull through cache access
resource "aws_iam_policy" "node_ecr_access" {
  name = replace("${local.region_prefix}-${local.env}-node-ecr-access", ".", "-")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Resource = "*",
        Sid      = "ECRPullThroughCacheAccess",
        Action = [
          "ecr:CreateRepository",
          "ecr:ReplicateImage",
          "ecr:BatchImportUpstreamImage"
        ]
      }
    ]
  })
}

data "aws_iam_policy" "inspector_ec2" {
  arn = "arn:aws:iam::aws:policy/AmazonInspector2ManagedCisPolicy"
}

data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Fetch details for each subnet using remote state
data "aws_subnet" "selected" {
  count = length(data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin)
  id    = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin[count.index]
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.26.0"
  # version = "~> 20.26.0"

  # EKS Cluster name
  cluster_name = local.eks_cluster_name

  # EKS Cluster version
  cluster_version = local.cluster_version

  # Network Configuration
  vpc_id                                = local.vpc_id
  subnet_ids                            = local.eks_private_subnets
  cluster_additional_security_group_ids = [local.eks_security_group]
  create_cluster_security_group         = false
  create_node_security_group            = false

  # Enable public endpoint connectivity from trusted external IP
  cluster_endpoint_public_access = local.cluster_endpoint_public_access_enabled

  # Public IPs for accessing EKS API server (Only needed for aws-external account)
  #cluster_endpoint_public_access_cidrs = local.cluster_endpoint_public_access_cidrs

  # Enable irsa but most pods should be using pod identity mechanism for IAM.
  enable_irsa = true

  bootstrap_self_managed_addons = false

  # Cloudwatch Logs Log Group to write to
  cloudwatch_log_group_kms_key_id = local.cloudwatch_log_group_kms_arn

  cloudwatch_log_group_tags = {
    ExportToS3 = "true"
  }

  # Additional IAM Role for Logging to Cloudwatch Logs and ecr access
  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      cloudwatch = aws_iam_policy.node_cloudwatch_access.arn
      ecr        = aws_iam_policy.node_ecr_access.arn
      guardduty  = aws_iam_policy.custom_guardduty_access.arn
      ssm        = data.aws_iam_policy.ssm_core.arn
      inspector  = data.aws_iam_policy.inspector_ec2.arn
    }
  }

  # Control Plane logs to capture to Cloudwatch Logs
  cluster_enabled_log_types = local.cluster_enabled_log_types

  # Access entries
  access_entries = local.access_entries

  # Cluster secrets encryption
  create_kms_key            = false
  cluster_encryption_config = local.cluster_encryption_config

  # EKS node group configurations to be deployed
  eks_managed_node_groups = local.managed_node_group_config

  # EKS Addons
  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "0.25"
            memory = "256M"
          }
          requests = {
            cpu    = "0.25"
            memory = "256M"
          }
        }
        tolerations = [
          {
            key : "architecture_linux-arm64"
            operator : "Exists"
          },
          {
            key      = "dedicated"
            operator = "Equal"
            value    = "infra"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          # nodegroup = local.eks_node_group_name["infra_nodegrp"]
          dedicated = "infra"
        }
        podDisruptionBudget = {
          maxUnavailable = 1
        }
      })
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        "env" = {
          # Disable IPv6
          "DISABLE_POD_V6"   = "true"
          "ENABLE_V6_EGRESS" = "false"
        }
      })
      tolerations = [
        {
          key      = "dedicated"
          operator = "Equal"
          value    = "infra"
          effect   = "NoSchedule"
        },
        {
          key : "architecture_linux-arm64"
          operator : "Exists"
        },
      ]
    }
    kube-proxy = {
      most_recent = true
      tolerations = [
        {
          key      = "dedicated"
          operator = "Equal"
          value    = "infra"
          effect   = "NoSchedule"
        },
        {
          key : "architecture_linux-arm64"
          operator : "Exists"
        },
      ]
    }
    eks-pod-identity-agent = {
      most_recent = true
      configuration_values = jsonencode({
        tolerations = [
          {
            key      = "dedicated"
            operator = "Equal"
            value    = "infra"
            effect   = "NoSchedule"
          },
          {
            key : "architecture_linux-arm64"
            operator : "Exists"
          },
        ]
      })
    }
  }

  # EKS Cluster tags
  tags = local.eks_cluster_tags

}


data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}
