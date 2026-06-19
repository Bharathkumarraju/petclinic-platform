# data "aws_iam_roles" "sso_admin_ro" {
#   path_prefix = "/aws-reserved/sso.amazonaws.com/ap-southeast-1/"
#   name_regex  = "^AWSReservedSSO_abaxx-sso-staging-dev-access_.*$"
# }

# data "aws_iam_roles" "sso_admin_rw" {
#   path_prefix = "/aws-reserved/sso.amazonaws.com/ap-southeast-1/"
#   name_regex  = "^AWSReservedSSO_abaxx-sso-admin-rw_.*$"
# }

data "aws_iam_roles" "abaxx_awssso_infra" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/ap-southeast-1/"
  name_regex  = "^AWSReservedSSO_abaxx-awssso-infra_.*$"
}

data "aws_iam_roles" "abaxx_awssso_developer" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/ap-southeast-1/"
  name_regex  = "^AWSReservedSSO_abaxx-awssso-developer_.*$"
}

data "aws_iam_roles" "abaxx_awssso_staging_admin" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/ap-southeast-1/"
  name_regex  = "^AWSReservedSSO_abaxx-awssso-staging-admin_.*$"
}

locals {

  # Get all required KMS Keys from remote state
  ebs_kms_arn                  = data.terraform_remote_state.ebs-kms-keys.outputs.kms_key_ec2_ebs_sin.arn
  cloudwatch_log_group_kms_arn = data.terraform_remote_state.kms_cloudwatch_logs.outputs.kms_key_cloudwatch_logs_sin.arn
  secrets_manager_kms_arn      = data.terraform_remote_state.secrets-kms-keys.outputs.kms_key_secrets_mgr_sin.arn
  # network_eks_access_role_arn      = data.terraform_remote_state.iam.outputs.network_eks_access_service_role_arn_sin
  network_dev_eks_access_role_arn = data.terraform_remote_state.iam.outputs.network_dev_eks_access_service_role_arn_sin

  # EKS Cluster name
  cluster_prefix   = "abex-exch"
  region_prefix    = "aps1"
  eks_cluster_name = "${local.cluster_prefix}-${local.region_prefix}-${local.env}-eks"

  # EKS Cluster version
  cluster_version = "1.34"


  # Get all network objects from remote state
  vpc_id              = data.terraform_remote_state.network.outputs.main_vpc_id_sin
  eks_private_subnets = data.terraform_remote_state.network.outputs.main_vpc_private_subnets_sin
  eks_security_group  = data.terraform_remote_state.network-layer-1.outputs.eks_cluster_sg_id_sin

  # Enable EKS cluster for public IP access
  cluster_endpoint_public_access_enabled = false

  # List of public IPs that can access cluster API server
  # cluster_endpoint_public_access_cidrs = [
  #   "203.149.193.138/32", # TWP IPs
  #   "118.189.14.114/32",  # Office IP
  #   "54.254.26.236/32",   # Palo Alto IP 1 
  #   "18.143.82.203/32",   # Palo Alto IP 2
  #   "18.142.188.83/32"    # AWS-Infra IP for atlantis connectivity
  # ]

  # Define the type of K8S control plane logs to capture
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # sso_admin_ro_arn = one(data.aws_iam_roles.sso_admin_ro.arns)
  # sso_admin_rw_arn = one(data.aws_iam_roles.sso_admin_rw.arns)
  abaxx_awssso_developer     = one(data.aws_iam_roles.abaxx_awssso_developer.arns)
  abaxx_awssso_infra         = one(data.aws_iam_roles.abaxx_awssso_infra.arns)
  abaxx_awssso_staging_admin = one(data.aws_iam_roles.abaxx_awssso_staging_admin.arns)

  # Define the group of users that should have access to cluster
  access_entries = {
    eks_cluster_admin = {
      principal_arn     = "arn:aws:iam::${local.account_id}:role/svc-eks-cluster-admin-${local.env}-sin"
      kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Grants cluster-wide access
          }
        }
      }
    }
    eks_cluster_readonly = {
      principal_arn     = "arn:aws:iam::${local.account_id}:role/svc-eks-cluster-readonly-${local.env}-sin"
      kubernetes_groups = ["cluster-readonly"]
      policy_associations = {
        readonly = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Cluster-wide readonly access
          }
        }
      }
    }
    # AWS SSO Admin user access 
    # aws_administrator_access = {
    #   principal_arn     = local.sso_admin_rw_arn
    #   kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
    #   policy_associations = {
    #     admin = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    #       access_scope = {
    #         namespaces = []
    #         type       = "cluster" # Grants cluster-wide access
    #       }
    #     }
    #   }
    # }
    # AWS SSO read-only Admin user access 
    # aws_readonly_access = {
    #   principal_arn     = local.sso_admin_ro_arn
    #   kubernetes_groups = ["cluster-readonly"]
    #   policy_associations = {
    #     readonly = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
    #       access_scope = {
    #         namespaces = []
    #         type       = "cluster" # Cluster-wide readonly access
    #       }
    #     }
    #   }
    # }
    # AWS SSO Developer user access 
    aws_developer_access = {
      principal_arn     = local.abaxx_awssso_developer
      kubernetes_groups = ["cluster-readonly"]
      policy_associations = {
        readonly = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Cluster-wide readonly access
          }
        }
      }
    }
    # AWS SSO Infra user access
    aws_infra_access = {
      principal_arn     = local.abaxx_awssso_infra
      kubernetes_groups = ["cluster-readonly"]
      policy_associations = {
        readonly = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Cluster-wide readonly access
          }
        }
      }
    }
    # AWS SSO Admin user access 
    aws_administrator_access = {
      principal_arn     = local.abaxx_awssso_staging_admin
      kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Grants cluster-wide access
          }
        }
      }
    }
    # terraform provisioner Admin access
    abaxx_terraform_provisioner = {
      principal_arn     = "arn:aws:iam::${local.account_id}:role/abaxx-exch-terraform-provisioner"
      kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Grants cluster-wide access
          }
        }
      }
    }
    # Github runner Admin access
    github_actions = {
      principal_arn     = "arn:aws:iam::${local.account_id}:role/svc-github-actions-${local.env}-sin"
      kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Grants cluster-wide access
          }
        }
      }
    }
    github_runner_infra = {
      principal_arn     = "arn:aws:iam::674146308744:role/svc-ec2-github-runner-infra-sin"
      kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Grants cluster-wide access
          }
        }
      }
    }
    github_runner_network = {
      principal_arn     = "arn:aws:iam::120430566909:role/svc-ec2-github-runner-network-sin"
      kubernetes_groups = [] # Remove system:masters since it is giving error as The kubernetes group name system:masters is invalid, it cannot start with system
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster" # Grants cluster-wide access
          }
        }
      }
    }
    # network_eks_access = {
    #   principal_arn     = "${local.network_eks_access_role_arn}"
    #   kubernetes_groups = []
    #   policy_associations = {
    #     admin = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    #       access_scope = {
    #         namespaces = []
    #         type       = "cluster"
    #       }
    #     }
    #   }
    # }
    network_dev_eks_access = {
      principal_arn     = "${local.network_dev_eks_access_role_arn}"
      kubernetes_groups = []
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  # Cluster secrets encryption
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = local.secrets_manager_kms_arn
  }

  # Tags for Cluster and node groups
  tags = {
    "Environment"  = "${local.env}"
    "Name"         = "abex-eks-node"
    "map-migrated" = "mig46499"
  }

  # EKS Cluster tags
  eks_cluster_tags = {
    "Name"         = "${local.eks_cluster_name}"
    "purpose"      = "Cluster to host containers"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # EKS node IAM role tags
  eks_nodegroup_iam_role_tags = { "org_network-ecr-pull" = "true" }

  # EKS node tags
  eks_infra_nodegrp_tags = {
    "Name"         = "${local.cluster_prefix}-node-${local.env}"
    "purpose"      = "Node Group to host kube-system and infra-related containers"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }


  # EKS node tags
  eks_abex_eks_nodegrp_1_tags = {
    "Name"         = "${local.cluster_prefix}-node-${local.env}"
    "purpose"      = "Node Group to host containers"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # EKS service mesh node group tags
  eks_servicemesh_nodegrp_tags = {
    "Name"         = "${local.cluster_prefix}-node-${local.env}"
    "purpose"      = "Node Group for service mesh POC - Linkerd / Istio / Cilium"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # EKS Add-ons tags
  eks_add_ons_tags = {
    "Name"         = "${local.eks_cluster_name}"
    "purpose"      = "EKS Add-ons added to EKS cluster"
    "env"          = local.env
    "map-migrated" = "mig46499"
  }

  # EKS node group name
  eks_node_group_name = {
    infra_nodegrp            = "abex-eks-infra-${local.env}"
    infra_nodegrp_arm64_1    = "infra-t-large-arm64-01"
    abex_eks_nodegrp_1       = "abex-eks-app-01-${local.env}"
    abex_eks_nodegrp_arm64_1 = "app-t-xlarge-arm64-01"
    servicemesh_linkerd      = "servicemesh-linkerd"
    servicemesh_istio        = "servicemesh-istio"
    servicemesh_cilium       = "servicemesh-cilium"
  }

  # Default root drive mapping for node groups
  default_root_block_device = {
    device_name = "/dev/xvda"
    ebs = {
      volume_size = 20
      kms_key_id  = local.ebs_kms_arn
      encrypted   = true
      volume_type = "gp3"
    }
  }

  # default_root_block_device_v2 = {
  #   device_name = "/dev/xvda"
  #   ebs = {
  #     # volume_size = 20
  #     kms_key_id  = local.ebs_kms_arn
  #     encrypted   = true
  #     volume_type = "gp3"
  #   }
  # }
  parameter_map = zipmap(
    data.aws_ssm_parameters_by_path.bottlerocket.names,
    data.aws_ssm_parameters_by_path.bottlerocket.values
  )

  ami_release_version = nonsensitive(local.parameter_map["/aws/service/bottlerocket/aws-k8s-${local.cluster_version}/x86_64/latest/image_version"])

  # EKS node group configurations to be deployed
  managed_node_group_config = {
    infra_nodegrp = {
      name                     = local.eks_node_group_name["infra_nodegrp"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 0
      max_size                 = 5
      desired_size             = 0
      update_config = {
        max_unavailable = 1
      }

      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_x86_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["m6a.large", "t3a.large"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      block_device_mappings = [
        local.default_root_block_device
      ]
      # Infra node taints
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "infra"
          effect = "NO_SCHEDULE"
        }
      }
      # Infra node labels
      labels = {
        dedicated = "infra"
        env       = "${local.env}"
        nodegroup = local.eks_node_group_name["infra_nodegrp"]
        purpose   = "infra"
        type      = "infra"
      }

      # EKS Node tags
      tags          = local.eks_infra_nodegrp_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },
    infra_nodegrp_arm64_1 = {
      name                     = local.eks_node_group_name["infra_nodegrp_arm64_1"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 2
      max_size                 = 4
      desired_size             = 2
      update_config = {
        max_unavailable = 1
      }

      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_ARM_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["t4g.large"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      block_device_mappings = [
        # we no longer need this, encryption, volume type is default already
        # local.default_root_block_device
      ]
      # Infra node taints
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "infra"
          effect = "NO_SCHEDULE"
        }
        # architecture = {
        #   key    = "architecture_linux-arm64"
        #   value  = "true"
        #   effect = "NO_SCHEDULE"
        # }
      }
      # Infra node labels
      labels = {
        dedicated = "infra"
        env       = "${local.env}"
        nodegroup = local.eks_node_group_name["infra_nodegrp"]
        purpose   = "infra"
        type      = "infra"
      }

      # EKS Node tags
      tags          = local.eks_infra_nodegrp_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },
    abex_eks_nodegrp_1 = {
      name                     = local.eks_node_group_name["abex_eks_nodegrp_1"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 5
      max_size                 = 10
      desired_size             = 5
      update_config = {
        max_unavailable = 2
      }
      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_x86_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["m6a.xlarge", "t3a.xlarge"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      block_device_mappings = [
        local.default_root_block_device
      ]
      # Generic app node labels
      labels = {
        env       = "${local.env}"
        nodegroup = local.eks_node_group_name["abex_eks_nodegrp_1"]
        purpose   = "app"
        type      = "generic"
      }
      # EKS Node tags
      tags          = local.eks_abex_eks_nodegrp_1_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },
    abex_eks_nodegrp_arm64_1 = {
      name                     = local.eks_node_group_name["abex_eks_nodegrp_arm64_1"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 2
      max_size                 = 10
      desired_size             = 2
      update_config = {
        max_unavailable = 2
      }
      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_ARM_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["t4g.xlarge"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      # block_device_mappings = [
      #   local.default_root_block_device
      # ]
      taints = {

        architecture = {
          key    = "architecture_linux-arm64"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
      # Generic app node labels
      labels = {
        env       = "${local.env}"
        nodegroup = local.eks_node_group_name["abex_eks_nodegrp_arm64_1"]
        purpose   = "app"
        type      = "generic"
      }
      # EKS Node tags
      tags          = local.eks_abex_eks_nodegrp_1_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },

    # ── Service mesh POC node groups ─────────────────────────────────────────
    servicemesh_linkerd = {
      name                     = local.eks_node_group_name["servicemesh_linkerd"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 2
      max_size                 = 4
      desired_size             = 2
      update_config = {
        max_unavailable = 1
      }
      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_x86_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["t3a.large"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      block_device_mappings                 = [local.default_root_block_device]
      taints = {
        mesh = {
          key    = "mesh"
          value  = "linkerd"
          effect = "NO_SCHEDULE"
        }
      }
      labels = {
        env       = local.env
        nodegroup = local.eks_node_group_name["servicemesh_linkerd"]
        mesh      = "linkerd"
        purpose   = "servicemesh"
      }
      tags          = local.eks_servicemesh_nodegrp_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },

    servicemesh_istio = {
      name                     = local.eks_node_group_name["servicemesh_istio"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 2
      max_size                 = 4
      desired_size             = 2
      update_config = {
        max_unavailable = 1
      }
      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_x86_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["t3a.large"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      block_device_mappings                 = [local.default_root_block_device]
      taints = {
        mesh = {
          key    = "mesh"
          value  = "istio"
          effect = "NO_SCHEDULE"
        }
      }
      labels = {
        env       = local.env
        nodegroup = local.eks_node_group_name["servicemesh_istio"]
        mesh      = "istio"
        purpose   = "servicemesh"
      }
      tags          = local.eks_servicemesh_nodegrp_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },

    servicemesh_cilium = {
      name                     = local.eks_node_group_name["servicemesh_cilium"]
      use_name_prefix          = false
      iam_role_use_name_prefix = false
      min_size                 = 2
      max_size                 = 4
      desired_size             = 2
      update_config = {
        max_unavailable = 1
      }
      capacity_type                         = "ON_DEMAND"
      ami_type                              = "BOTTLEROCKET_x86_64"
      ami_release_version                   = local.ami_release_version
      instance_types                        = ["t3a.large"]
      attach_cluster_primary_security_group = true
      subnet_ids                            = local.eks_private_subnets
      block_device_mappings                 = [local.default_root_block_device]
      taints = {
        mesh = {
          key    = "mesh"
          value  = "cilium"
          effect = "NO_SCHEDULE"
        }
      }
      labels = {
        env       = local.env
        nodegroup = local.eks_node_group_name["servicemesh_cilium"]
        mesh      = "cilium"
        purpose   = "servicemesh"
      }
      tags          = local.eks_servicemesh_nodegrp_tags
      iam_role_tags = local.eks_nodegroup_iam_role_tags
    },
  }
}

