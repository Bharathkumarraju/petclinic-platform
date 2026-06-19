# ─────────────────────────────────────────────────────────────────────────────
# Service Mesh POC — Linkerd, Istio Ambient, Cilium
#
# Each mesh runs on dedicated node groups defined in 02-eks-base/locals.tf.
# Node groups carry: label mesh=<name>, taint mesh=<name>:NoSchedule
# Each mesh's components are pinned via nodeSelector/affinity + matching tolerations.
# ─────────────────────────────────────────────────────────────────────────────

# ══ LINKERD ══════════════════════════════════════════════════════════════════
# Trust anchor: self-signed root CA (10 years) — store in Terraform state (encrypted).
# Identity issuer: intermediate CA (1 year) signed by trust anchor.
# cert-manager (already installed) can handle issuer rotation going forward.

resource "tls_private_key" "linkerd_trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "linkerd_trust_anchor" {
  private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem

  subject {
    common_name = "root.linkerd.cluster.local"
  }

  validity_period_hours = 87600 # 10 years
  is_ca_certificate     = true
  set_subject_key_id    = true

  allowed_uses = ["cert_signing", "crl_signing"]
}

resource "tls_private_key" "linkerd_identity_issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "linkerd_identity_issuer" {
  private_key_pem = tls_private_key.linkerd_identity_issuer.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "linkerd_identity_issuer" {
  cert_request_pem   = tls_cert_request.linkerd_identity_issuer.cert_request_pem
  ca_private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.linkerd_trust_anchor.cert_pem

  validity_period_hours = 8760 # 1 year
  is_ca_certificate     = true
  set_subject_key_id    = true

  allowed_uses = ["cert_signing", "crl_signing"]
}

resource "helm_release" "linkerd_crds" {
  name             = "linkerd-crds"
  namespace        = "linkerd"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-crds"
  version          = "1.8.0"
  create_namespace = true
  timeout          = 300
}

resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  namespace  = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-control-plane"
  version    = "1.16.11"
  depends_on = [helm_release.linkerd_crds]
  timeout    = 600

  values = [
    yamlencode({
      identityTrustAnchorsPEM = tls_self_signed_cert.linkerd_trust_anchor.cert_pem
      identity = {
        issuer = {
          tls = {
            crtPEM = tls_locally_signed_cert.linkerd_identity_issuer.cert_pem
            keyPEM = tls_private_key.linkerd_identity_issuer.private_key_pem
          }
        }
      }
      # Pin all control-plane components to linkerd node group
      nodeSelector = { mesh = "linkerd" }
      tolerations = [{
        key    = "mesh"
        value  = "linkerd"
        effect = "NoSchedule"
      }]
    })
  ]
}

resource "helm_release" "linkerd_viz" {
  name             = "linkerd-viz"
  namespace        = "linkerd-viz"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-viz"
  version          = "30.12.11"
  create_namespace = true
  depends_on       = [helm_release.linkerd_control_plane]
  timeout          = 600

  values = [
    yamlencode({
      # Top-level nodeSelector applies to tap, web, tap-injector
      nodeSelector = { mesh = "linkerd" }
      tolerations = [{
        key    = "mesh"
        value  = "linkerd"
        effect = "NoSchedule"
      }]
      # metrics-api and prometheus need their own nodeSelector
      metricsAPI = {
        nodeSelector = { mesh = "linkerd" }
        tolerations = [{
          key    = "mesh"
          value  = "linkerd"
          effect = "NoSchedule"
        }]
      }
      prometheus = {
        nodeSelector = { mesh = "linkerd" }
        tolerations = [{
          key    = "mesh"
          value  = "linkerd"
          effect = "NoSchedule"
        }]
      }
    })
  ]
}

# ══ ISTIO AMBIENT ═════════════════════════════════════════════════════════════
# Gateway API CRDs are a hard prerequisite for waypoint proxies (L7).
# No Helm chart exists — applied via kubectl using the cluster's own credentials.

resource "null_resource" "gateway_api_crds" {
  triggers = {
    # Re-apply if the version changes
    gateway_api_version = "v1.5.1"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      CA_CERT_FILE=$(mktemp)
      trap 'rm -f "$CA_CERT_FILE"' EXIT
      echo "${base64decode(local.eks_cluster_ca_certificate)}" > "$CA_CERT_FILE"
      kubectl apply \
        --server="${local.eks_cluster_endpoint}" \
        --token="${data.aws_eks_cluster_auth.cluster_auth.token}" \
        --certificate-authority="$CA_CERT_FILE" \
        -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
    EOT
  }
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  namespace        = "istio-system"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = "1.30.1"
  create_namespace = true
  depends_on       = [null_resource.gateway_api_crds]
  timeout          = 300

  set {
    name  = "defaultRevision"
    value = "default"
  }
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.30.1"
  depends_on = [helm_release.istio_base]
  timeout    = 600

  values = [
    yamlencode({
      profile      = "ambient"
      nodeSelector = { mesh = "istio" }
      tolerations = [{
        key    = "mesh"
        value  = "istio"
        effect = "NoSchedule"
      }]
      pilot = {
        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "512Mi" }
        }
      }
    })
  ]
}

resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  version    = "1.30.1"
  depends_on = [helm_release.istiod]
  timeout    = 300

  values = [
    yamlencode({
      profile = "ambient"
      cni     = { ambient = { enabled = true } }
      # Pin CNI DaemonSet to istio nodes — prevents it running on linkerd/cilium nodes
      nodeSelector = { mesh = "istio" }
      tolerations = [{
        key    = "mesh"
        value  = "istio"
        effect = "NoSchedule"
      }]
    })
  ]
}

resource "helm_release" "ztunnel" {
  name       = "ztunnel"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "ztunnel"
  version    = "1.30.1"
  depends_on = [helm_release.istio_cni]
  timeout    = 300

  values = [
    yamlencode({
      # Pin ztunnel DaemonSet to istio nodes — prevents it running on linkerd/cilium nodes
      nodeSelector = { mesh = "istio" }
      tolerations = [{
        key    = "mesh"
        value  = "istio"
        effect = "NoSchedule"
      }]
    })
  ]
}

# ══ CILIUM ═══════════════════════════════════════════════════════════════════
# CNI chaining mode — runs on top of the existing AWS VPC CNI.
# No node drain or IP disruption; policies are enforced via eBPF.
# Both cilium (agent) and cilium-envoy DaemonSets pinned to mesh=cilium nodes.

resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.19.4"
  timeout    = 600

  values = [
    yamlencode({
      # CNI chaining — coexists with VPC CNI
      cni = {
        chainingMode = "aws-cni"
        exclusive    = false
      }

      # Native routing via VPC routes (no overlay)
      routingMode          = "native"
      endpointRoutes       = { enabled = true }
      enableIPv4Masquerade = false

      # IPAM delegated to VPC CNI
      ipam = { mode = "cluster-pool" }

      # Preserve kube-proxy (not replacing it)
      kubeProxyReplacement = false

      # Hubble observability
      hubble = {
        enabled = true
        relay = {
          enabled = true
          tolerations = [{
            key    = "mesh"
            value  = "cilium"
            effect = "NoSchedule"
          }]
        }
        ui = {
          enabled = true
          tolerations = [{
            key    = "mesh"
            value  = "cilium"
            effect = "NoSchedule"
          }]
        }
        metrics = { enabled = ["dns", "drop", "tcp", "flow", "icmp", "http"] }
      }

      prometheus = { enabled = true }
      operator   = { prometheus = { enabled = true } }

      # Pin cilium agent DaemonSet to cilium nodes
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [{
              matchExpressions = [{
                key      = "mesh"
                operator = "In"
                values   = ["cilium"]
              }]
            }]
          }
        }
      }

      # Pin cilium-envoy DaemonSet to cilium nodes (must be set separately)
      envoy = {
        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "mesh"
                  operator = "In"
                  values   = ["cilium"]
                }]
              }]
            }
          }
        }
      }

      # Allow cilium agent pods to schedule on tainted cilium nodes
      tolerations = [{
        key    = "mesh"
        value  = "cilium"
        effect = "NoSchedule"
      }]
    })
  ]
}
