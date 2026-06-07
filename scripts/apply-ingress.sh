#!/usr/bin/env bash
# Apply ALB Ingress manifests to all 3 EKS clusters.
# Reads the ACM certificate ARN from shared Terraform state and substitutes it
# into each ingress manifest before applying.
# Prerequisites: aws CLI, kubectl, terraform; LBC must already be installed.

set -euo pipefail

REGION="eu-central-1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read cert ARN from shared Terraform state
CERT_ARN=$(terraform -chdir="${REPO_ROOT}/terraform/environments/shared" \
  output -raw certificate_arn)

echo "Using ACM certificate ARN: ${CERT_ARN}"

MESHES=(
  "linkerd:petclinic-linkerd:petclinic-linkerd"
  "istio:petclinic-istio:petclinic-istio"
  "cilium:petclinic-cilium:petclinic-cilium"
)

apply_ingress() {
  local mesh="$1"
  local cluster_name="$2"
  local namespace="$3"

  echo ""
  echo "==> Applying Ingress to ${cluster_name} (namespace=${namespace})"

  aws eks update-kubeconfig \
    --region "${REGION}" \
    --name "${cluster_name}" \
    --alias "${cluster_name}"

  # Ensure namespace exists
  kubectl --context="${cluster_name}" get namespace "${namespace}" >/dev/null 2>&1 || \
    kubectl --context="${cluster_name}" create namespace "${namespace}"

  # Substitute cert ARN placeholder and apply
  sed "s|CERTIFICATE_ARN|${CERT_ARN}|g" \
    "${REPO_ROOT}/k8s/base/ingress/${mesh}-ingress.yaml" | \
    kubectl --context="${cluster_name}" apply -f -

  echo "    Ingress applied. Waiting for ALB to provision..."
  kubectl --context="${cluster_name}" wait ingress/petclinic-ingress \
    --namespace="${namespace}" \
    --for=jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
    --timeout=300s 2>/dev/null || true

  local alb_hostname
  alb_hostname=$(kubectl --context="${cluster_name}" get ingress petclinic-ingress \
    --namespace="${namespace}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

  echo "    ALB hostname: ${alb_hostname}"
}

for entry in "${MESHES[@]}"; do
  IFS=':' read -r mesh cluster ns <<< "${entry}"
  apply_ingress "${mesh}" "${cluster}" "${ns}"
done

echo ""
echo "==> All Ingress resources applied."
echo "    Run scripts/update-dns.sh to create Route53 CNAME records once ALBs are ready."
