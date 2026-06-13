#!/usr/bin/env bash
# Deploy full observability stack (Prometheus, Grafana, Loki, FluentBit, Zipkin, Alertmanager)
# to all three petclinic clusters: linkerd, istio, cilium.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VALUES_DIR="${REPO_ROOT}/helm-values/monitoring"
K8S_OBS="${REPO_ROOT}/k8s/base/observability"

MESHES=(linkerd istio cilium)
ACCOUNT_ID="172586632398"
REGION="eu-central-1"

context_for() { echo "arn:aws:eks:${REGION}:${ACCOUNT_ID}:cluster/petclinic-${1}"; }

# ── Helm repos ──────────────────────────────────────────────────────────────
echo "=== Adding Helm repos ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana               https://grafana.github.io/helm-charts
helm repo add fluent                https://fluent.github.io/helm-charts
helm repo update

# ── Per-cluster deployment ───────────────────────────────────────────────────
for mesh in "${MESHES[@]}"; do
  CTX="$(context_for "${mesh}")"
  echo ""
  echo "════════════════════════════════════════"
  echo " Deploying to petclinic-${mesh}"
  echo "════════════════════════════════════════"

  # Namespaces
  echo "  [1/6] Namespaces"
  kubectl apply -f "${K8S_OBS}/namespaces.yaml" --context "${CTX}"

  # kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
  echo "  [2/6] kube-prometheus-stack"
  helm upgrade --install kube-prometheus-stack \
    prometheus-community/kube-prometheus-stack \
    --kube-context "${CTX}" \
    --namespace monitoring \
    --version 65.1.1 \
    -f "${VALUES_DIR}/prometheus-stack.yaml" \
    --timeout 10m

  # Loki
  echo "  [3/6] Loki"
  helm upgrade --install loki \
    grafana/loki \
    --kube-context "${CTX}" \
    --namespace monitoring \
    --version 6.18.0 \
    -f "${VALUES_DIR}/loki.yaml" \
    --timeout 5m

  # FluentBit
  echo "  [4/6] FluentBit"
  helm upgrade --install fluent-bit \
    fluent/fluent-bit \
    --kube-context "${CTX}" \
    --namespace monitoring \
    --version 0.47.9 \
    -f "${VALUES_DIR}/fluent-bit.yaml" \
    --timeout 5m

  # Zipkin
  echo "  [5/6] Zipkin"
  kubectl apply -f "${K8S_OBS}/zipkin.yaml" --context "${CTX}"

  # Alert rules (PrometheusRule CRD — needs Prometheus Operator installed first)
  echo "  [6/6] Alert rules"
  kubectl apply -f "${K8S_OBS}/alert-rules.yaml" --context "${CTX}"

  echo "  Done: petclinic-${mesh}"
done

echo ""
echo "=== Observability stack deployed to all 3 clusters ==="
echo ""
echo "Port-forward commands to access UIs:"
for mesh in "${MESHES[@]}"; do
  CTX="$(context_for "${mesh}")"
  echo "  # ${mesh}:"
  echo "  kubectl port-forward svc/kube-prometheus-stack-grafana     3000:80  -n monitoring --context ${CTX}"
  echo "  kubectl port-forward svc/kube-prometheus-stack-prometheus  9090:9090 -n monitoring --context ${CTX}"
  echo "  kubectl port-forward svc/zipkin                            9411:9411 -n tracing    --context ${CTX}"
  echo ""
done
