data "aws_eks_cluster_auth" "cluster_auth" {
  name = local.eks_cluster_name
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}




# # Metrics server installation to run K top Nodes
resource "helm_release" "metrics_server" {
  name      = "metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.13.0"

  set {
    name  = "containerPort"
    value = 10251 #10251 must be used due to fargates
  }

}


# Install kube-state-metrics for Elastic to get all the metrics
# necessary to function correctly
resource "helm_release" "kube_state_metrics" {
  name      = "kube-state-metrics"
  namespace = "kube-system"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "7.3.0"

}

# AWS EBS CSI Driver
resource "helm_release" "aws_ebs_csi_addons" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.59.0"
  values = [
    "${file("./config/aws-ebs-csi-values.yaml")}"
  ]

}

# AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.2.2"

  values = [
    jsonencode({
      clusterName : local.eks_cluster_name
      region : local.vpc_region
      defaultTargetType : local.default_target_type
      nodeSelector : {
        dedicated : "infra"
      },
      tolerations : [
        {
          key : "dedicated",
          operator : "Equal",
          value : "infra"
        }
      ]
    })
  ]
}


# External Secrets Operator
resource "helm_release" "external_secrets_operator" {
  name             = "external-secrets-operator"
  namespace        = "external-secrets"
  create_namespace = true
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.4.1"
}

# Teleport agent for teleport-cloud version

resource "helm_release" "teleportcloud_kube_agent" {
  name             = "teleportcloud-kube-agent"
  namespace        = "teleportcloud-kube-agent"
  create_namespace = true

  repository = "https://charts.releases.teleport.dev"
  chart      = "teleport-kube-agent"
  version    = "18.6.2"

  values = [
    templatefile("${path.module}/config/teleportcloud-kube-agent.yaml", {
      env                 = local.env
      eks_cluster_name    = local.eks_cluster_name
      teleport_proxy_addr = "abaxx.teleport.sh:443"
      app_namespaces      = ["acs-swift-relay-${local.env}", "clarity-${local.env}", "elastic-apm-${local.env}", "eprime-${local.env}", "mdapi-${local.env}", "mmtapi-${local.env}", "risk-${local.env}", "tradingview-${local.env}", "datawarehouse-${local.env}"]
      replica_count       = 2
      pdb_min_available   = 1
      databases           = local.teleport_databases
    })
  ]
}


resource "helm_release" "elastic_agent" {
  name      = "elastic-agent"
  namespace = "elastic-system"
  # force_update     = true
  create_namespace = true
  # repository = "https://${local.gh_token}@raw.githubusercontent.com/abaxxsingapore/abex-aws-eks-base/main/charts"

  # Use the token from an environment variable
  chart            = "https://${local.github_eks_base_token}:x-oauth-basic@raw.githubusercontent.com/abaxxsingapore/abex-aws-eks-base/main/charts/elastic-agent-${local.elastic_helm_chart_version}.tgz"
  version          = local.elastic_helm_chart_version
  pass_credentials = true

  set {
    name  = "fleet_enrollment_token"
    value = local.fleet_enrollment_token
  }
  set {
    name  = "resources.requests.memory"
    value = "1200Mi"
  }
  set {
    name  = "resources.limits.memory"
    value = "1200Mi"
  }
  set {
    name  = "elastic_agent_version"
    value = local.elastic_agent_version
  }
  set {
    name  = "elastic_agent_tags"
    value = local.elastic_agent_tags
  }
  set {
    name  = "fleet_url"
    value = local.fleet_url
  }
}

# resource "helm_release" "opentelemetry_collector" {
#   name         = "opentelemetry-collector"
#   namespace    = "elastic-system"
#   force_update = true
#   repository   = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#   chart        = "opentelemetry-collector"
#   version      = "0.108.1"

#   values = [
#     templatefile(
#       "./config/open-telemetry-collector.yaml",
#       {
#         elastic_apm_enrollment_token = local.elastic_apm_enrollment_token
#         elastic_apm_endpoint         = local.elastic_apm_endpoint
#       }
#     )
#   ]
# }

resource "helm_release" "opentelemetry_operator" {
  name             = "opentelemetry-operator"
  namespace        = "opentelemetry"
  create_namespace = true

  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-operator"
  version    = "0.99.0"

  set {
    name  = "manager.collectorImage.repository"
    value = "otel/opentelemetry-collector-k8s"
  }

  set {
    name  = "namespaceOverride"
    value = "opentelemetry"
  }
}


resource "helm_release" "abaxx_otel" {
  name             = "abaxx-otel"
  namespace        = "opentelemetry"
  create_namespace = true
  chart            = "https://${local.github_eks_base_token}:x-oauth-basic@raw.githubusercontent.com/abaxxsingapore/abex-aws-eks-base/main/charts/abaxx-otel-0.0.5.tgz"

  version          = "0.0.1"
  pass_credentials = true

  depends_on = [helm_release.opentelemetry_operator]

  set {
    name  = "global.env"
    value = local.env
  }
  set {
    name  = "global.awsAccount"
    value = tostring(local.aws_account)
  }
  set {
    name  = "apmServerEndpoint"
    value = "http://apm.staging.abex.int:8200"
  }
}

# External DNS to allows service/ingress annotation 
resource "helm_release" "external-dns" {
  name      = "external-dns"
  namespace = "kube-system"
  # create_namespace = true
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = "1.19.0"

  values = [
    "${file("./config/external-dns.yaml")}"
  ]

}


resource "helm_release" "apm_attacher" {
  name             = "apm-attacher"
  namespace        = "elastic-system"
  create_namespace = true
  repository       = "https://helm.elastic.co"
  chart            = "apm-attacher"
  version          = "1.1.3"

  values = [
    templatefile("${path.module}/config/elastic-apm-attacher.yaml", {
      elastic_apm_key          = local.elastic-apm-key
      apm_server_url           = "http://${local.elastic_apm_endpoint}"
      apm_target_namespaces    = local.apm-target-namespaces
      apm_application_packages = join(",", local.apm-application-packages)
      apm_env                  = local.env
      apm_image                = local.elastic-apm-image
      apm_image_tag            = local.elastic-apm-image-tag
    })
  ]

}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.20.2"

  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

