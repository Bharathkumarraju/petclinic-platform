#!/usr/bin/env bash
# Install Cilium on petclinic-cilium EKS cluster in CNI chaining mode.
# Runs on top of existing AWS VPC CNI — no node drain or IP disruption.
# Enables: CiliumNetworkPolicy, Hubble observability, eBPF-accelerated routing.
set -euo pipefail

CONTEXT="petclinic-cilium"
REGION="${AWS_DEFAULT_REGION:-eu-central-1}"
CLUSTER_NAME="petclinic-cilium"

CILIUM_VERSION="1.19.4"

echo "════════════════════════════════════════════════════════"
echo "  Installing Cilium on cluster: ${CONTEXT}"
echo "  Version: ${CILIUM_VERSION}  Mode: aws-cni chaining"
echo "════════════════════════════════════════════════════════"

# ── Resolve VPC ID ───────────────────────────────────────────────────────────
echo ""
echo "[1/3] Resolving VPC ID"
VPC_ID=$(aws eks describe-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${REGION}" \
  --query 'cluster.resourcesVpcConfig.vpcId' \
  --output text)
echo "    VPC ID: ${VPC_ID}"

# ── Install Cilium in chaining mode ─────────────────────────────────────────
echo ""
echo "[2/3] Installing Cilium (chart ${CILIUM_VERSION})"
helm upgrade --install cilium cilium/cilium \
  --kube-context "${CONTEXT}" \
  --namespace kube-system \
  --version "${CILIUM_VERSION}" \
  \
  `# CNI chaining — runs on top of AWS VPC CNI` \
  --set cni.chainingMode=aws-cni \
  --set cni.exclusive=false \
  \
  `# Routing — native (uses VPC routes, not overlay)` \
  --set routingMode=native \
  --set endpointRoutes.enabled=true \
  --set enableIPv4Masquerade=false \
  \
  `# IPAM — delegated to AWS VPC CNI` \
  --set ipam.mode=cluster-pool \
  \
  `# Keep kube-proxy (not replacing it)` \
  --set kubeProxyReplacement=false \
  \
  `# Hubble observability` \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
  \
  `# Prometheus metrics` \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true \
  \
  `# arm64 compatible (no special override needed for 1.19.x)` \
  --wait --timeout 10m

# ── Verify ───────────────────────────────────────────────────────────────────
echo ""
echo "[3/3] Verifying Cilium rollout"

echo ""
echo "Cilium pods:"
kubectl --context="${CONTEXT}" get pods -n kube-system \
  -l app.kubernetes.io/part-of=cilium 2>&1

echo ""
echo "Hubble relay:"
kubectl --context="${CONTEXT}" get pods -n kube-system \
  -l app.kubernetes.io/name=hubble-relay 2>&1

echo ""
echo "Hubble UI:"
kubectl --context="${CONTEXT}" get pods -n kube-system \
  -l app.kubernetes.io/name=hubble-ui 2>&1

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Cilium installation complete."
echo ""
echo "  Port-forward to access Hubble UI:"
echo "  kubectl port-forward svc/hubble-ui 12000:80 -n kube-system --context ${CONTEXT}"
echo ""
echo "  Apply CiliumNetworkPolicy in petclinic-cilium namespace to enforce mTLS-like policy."
echo "════════════════════════════════════════════════════════"
