# # import {
# #   to = aws_iam_policy.node_cloudwatch_access
# # }
# # import {
# #   to = module.eks.aws_cloudwatch_log_group.this[0]
# # }
# # import {
# #   to = module.eks.aws_ec2_tag.cluster_primary_security_group["env"]
# # }
# # import {
# #   to = module.eks.aws_ec2_tag.cluster_primary_security_group["map-migrated"]
# # }
# # import {
# #   to = module.eks.aws_ec2_tag.cluster_primary_security_group["purpose"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_entry.this["abaxx_terraform_provisioner"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_entry.this["aws_administrator_access"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_entry.this["aws_readonly_access"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_entry.this["github_actions"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_policy_association.this["abaxx_terraform_provisioner_admin"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_policy_association.this["aws_administrator_access_admin"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_policy_association.this["aws_readonly_access_readonly"]
# # }
# # import {
# #   to = module.eks.aws_eks_access_policy_association.this["github_actions_admin"]
# # }

# # import {
# #   to = module.eks.aws_eks_cluster.this[0]
# # }
# # import {
# #   to = module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
# # }
# # import {
# #   to = module.eks.aws_iam_policy.cluster_encryption[0]
# # }


# # import {
# #   to = module.eks.time_sleep.this[0]
# # }



# # EKS Cluster
# import {
#   to = module.eks.aws_eks_cluster.this[0]
#   id = "abex-exch-aps1-staging-eks"
# }

# # IAM Policies
# import {
#   to = aws_iam_policy.node_cloudwatch_access
#   id = "arn:aws:iam::993533333148:policy/aps1-staging-node-cloudwatch-access"
# }
# import {
#   to = aws_iam_policy.node_ecr_access
#   id = "arn:aws:iam::993533333148:policy/aps1-staging-node-ecr-access"
# }

# import {
#   to = module.eks.aws_iam_policy.cluster_encryption[0]
#   id = "arn:aws:iam::993533333148:policy/abex-exch-aps1-staging-eks-cluster-ClusterEncryption20230830065153814600000001"
# }

# # IAM Role for Node Group
# import {
#   to = module.eks.module.eks_managed_node_group["abex-eks-node"].aws_iam_role.this[0]
#   id = "abex-eks-node-eks-node-group-20240503074933241900000001"
# }

# import {
#   to = module.eks.aws_iam_role.this[0]
#   id = "abex-exch-aps1-staging-eks-cluster-20230830065153815700000005"
# }

# # IAM Role Policy Attachments for Node Group
# import {
#   to = module.eks.module.eks_managed_node_group["abex-eks-node"].aws_iam_role_policy_attachment.this["AmazonEKSWorkerNodePolicy"]
#   id = "abex-eks-node-eks-node-group-20240503074933241900000001/arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }
# import {
#   to = module.eks.module.eks_managed_node_group["abex-eks-node"].aws_iam_role_policy_attachment.this["AmazonEKS_CNI_Policy"]
#   id = "abex-eks-node-eks-node-group-20240503074933241900000001/arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }
# import {
#   to = module.eks.module.eks_managed_node_group["abex-eks-node"].aws_iam_role_policy_attachment.this["AmazonEC2ContainerRegistryReadOnly"]
#   id = "abex-eks-node-eks-node-group-20240503074933241900000001/arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }
# import {
#   to = module.eks.aws_iam_role_policy_attachment.additional["cloudwatch"]
#   id = "abex-exch-aps1-staging-eks-cluster-20230830065153815700000005/arn:aws:iam::993533333148:policy/aps1-staging-node-cloudwatch-access"
# }
# import {
#   to = module.eks.aws_iam_role_policy_attachment.cluster_encryption[0]
#   id = "abex-exch-aps1-staging-eks-cluster-20230830065153815700000005/arn:aws:iam::993533333148:policy/abex-exch-aps1-staging-eks-cluster-ClusterEncryption20230830065153814600000001"
# }
# import {
#   to = module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]
#   id = "abex-exch-aps1-staging-eks-cluster-20230830065153815700000005/arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }
# import {
#   to = module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"]
#   id = "abex-exch-aps1-staging-eks-cluster-20230830065153815700000005/arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
# }
# # Managed Node Group - abex-eks-node
# import {
#   to = module.eks.module.eks_managed_node_group["abex-eks-node"].aws_eks_node_group.this[0]
#   id = "abex-exch-aps1-staging-eks:abex-eks-node-20240912042841117300000002"
# }

# # Cloudwatch Log Group
# import {
#   to = module.eks.aws_cloudwatch_log_group.this[0]
#   id = "/aws/eks/abex-exch-aps1-staging-eks/cluster"
# }

# # Cluster OIDC Provider
# import {
#   to = module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
#   id = "arn:aws:iam::993533333148:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/3ED9C9C5936AD111C93EF43650A1B779"
# }

# # Launch Template
# import {
#   to = module.eks.module.eks_managed_node_group["abex-eks-node"].aws_launch_template.this[0]
#   id = "lt-085577caa8c572b04"
# }

# #EKS Access Entry

# import {
#   to = module.eks.aws_eks_access_entry.this["abaxx_terraform_provisioner"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::993533333148:role/abaxx-exch-terraform-provisioner"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["aws_administrator_access"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::993533333148:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSAdministratorAccess_c61a72c9f9fe3f36"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["aws_readonly_access"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::993533333148:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSReadOnlyAccess_992cc3f53d88d421"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["eks_cluster_admin"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::993533333148:role/svc-eks-cluster-admin-staging-sin"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["eks_cluster_readonly"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::993533333148:role/svc-eks-cluster-readonly-staging-sin"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["github_actions"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::993533333148:role/svc-github-actions-staging-sin"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["github_runner_infra"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::674146308744:role/svc-ec2-github-runner-infra-sin"
# }
# import {
#   to = module.eks.aws_eks_access_entry.this["github_runner_network"]
#   id = "abex-exch-aps1-staging-eks:arn:aws:iam::120430566909:role/svc-ec2-github-runner-network-sin"
# }

# # Import EKS Access Policy Associations
# import {
#   to = module.eks.aws_eks_access_policy_association.this["abaxx_terraform_provisioner_admin"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::993533333148:role/abaxx-exch-terraform-provisioner#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["aws_administrator_access_admin"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::993533333148:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSAdministratorAccess_c61a72c9f9fe3f36#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["aws_readonly_access_readonly"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::993533333148:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AWSReadOnlyAccess_992cc3f53d88d421#arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["eks_cluster_admin_admin"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::993533333148:role/svc-eks-cluster-admin-staging-sin#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["eks_cluster_readonly_readonly"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::993533333148:role/svc-eks-cluster-readonly-staging-sin#arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["github_actions_admin"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::993533333148:role/svc-github-actions-staging-sin#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["github_runner_infra_admin"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::674146308744:role/svc-ec2-github-runner-infra-sin#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }
# import {
#   to = module.eks.aws_eks_access_policy_association.this["github_runner_network_admin"]
#   id = "abex-exch-aps1-staging-eks#arn:aws:iam::120430566909:role/svc-ec2-github-runner-network-sin#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }

# // addons
# import {
#   to = module.eks.aws_eks_addon.this["coredns"]
#   id = "abex-exch-aps1-staging-eks:coredns"
# }
# import {
#   to = module.eks.aws_eks_addon.this["eks-pod-identity-agent"]
#   id = "abex-exch-aps1-staging-eks:eks-pod-identity-agent"
# }
# import {
#   to = module.eks.aws_eks_addon.this["kube-proxy"]
#   id = "abex-exch-aps1-staging-eks:kube-proxy"
# }
# import {
#   to = module.eks.aws_eks_addon.this["vpc-cni"]
#   id = "abex-exch-aps1-staging-eks:vpc-cni"
# }
