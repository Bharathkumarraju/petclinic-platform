#!/usr/bin/env bash
# Install External Secrets Operator on all 3 EKS clusters and apply
# ClusterSecretStore + ExternalSecret manifests for RDS credentials and
# OpenAI API key.
# Prerequisites: aws CLI, helm, kubectl, terraform outputs available.
# Run after: terraform apply for all 3 cluster environments.

set -euo pipefail

REGION="eu-central-1"
ESO_VERSION="2.4.1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MESHES=(
  "linkerd:petclinic-linkerd:petclinic-linkerd"
  "istio:petclinic-istio:petclinic-istio"
  "cilium:petclinic-cilium:petclinic-cilium"
)

install_eso() {
  local env="$1"
  local cluster_name="$2"
  local namespace="$3"

  echo ""
  echo "==> Installing ESO on ${cluster_name} (env=${env})"

  aws eks update-kubeconfig \
    --region "${REGION}" \
    --name "${cluster_name}" \
    --alias "${cluster_name}"

  # Get ESO IRSA role ARN from Terraform output
  local role_arn
  role_arn=$(terraform -chdir="${REPO_ROOT}/terraform/environments/${env}" \
    output -raw eso_role_arn)

  echo "    IRSA role: ${role_arn}"

  # Add the external-secrets Helm repo (idempotent)
  helm repo add latest-external-secrets https://charts.external-secrets.io 2>/dev/null || true
  helm repo update latest-external-secrets

  # Install / upgrade ESO — creates the external-secrets namespace and SA
  helm upgrade --install external-secrets latest-external-secrets/external-secrets \
    --namespace external-secrets \
    --create-namespace \
    --kube-context "${cluster_name}" \
    --set serviceAccount.name=external-secrets-sa \
    --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${role_arn}" \
    --set crds.install=true \
    --version "${ESO_VERSION}" \
    --wait \
    --timeout 5m

  echo "    ESO installed. Waiting for CRDs to be established..."
  kubectl --context="${cluster_name}" wait crd/clustersecretstores.external-secrets.io \
    --for=condition=Established --timeout=120s
  kubectl --context="${cluster_name}" wait crd/externalsecrets.external-secrets.io \
    --for=condition=Established --timeout=120s

  echo "    Applying ClusterSecretStore..."

  # Apply ClusterSecretStore
  kubectl --context="${cluster_name}" apply -f \
    "${REPO_ROOT}/k8s/base/external-secrets/cluster-secret-store.yaml"

  # Wait for ESO webhook to be ready before applying ExternalSecrets
  kubectl --context="${cluster_name}" rollout status deployment/external-secrets-webhook \
    --namespace external-secrets --timeout=120s

  echo "    Applying ExternalSecrets in namespace ${namespace}..."

  # Ensure the app namespace exists
  kubectl --context="${cluster_name}" get namespace "${namespace}" >/dev/null 2>&1 || \
    kubectl --context="${cluster_name}" create namespace "${namespace}"

  # Apply ExternalSecrets with namespace substituted
  sed "s|MESH_NAMESPACE|${namespace}|g" \
    "${REPO_ROOT}/k8s/base/external-secrets/rds-credentials-es.yaml" | \
    kubectl --context="${cluster_name}" apply -f -

  sed "s|MESH_NAMESPACE|${namespace}|g" \
    "${REPO_ROOT}/k8s/base/external-secrets/openai-api-key-es.yaml" | \
    kubectl --context="${cluster_name}" apply -f -

  echo "    Waiting for secrets to sync..."
  sleep 10

  # Show sync status
  kubectl --context="${cluster_name}" get externalsecret \
    --namespace "${namespace}" 2>/dev/null || true

  echo "    Done: ${cluster_name}"
}

for entry in "${MESHES[@]}"; do
  IFS=':' read -r env cluster ns <<< "${entry}"
  install_eso "${env}" "${cluster}" "${ns}"
done

echo ""
echo "==> ESO installed and secrets synced on all 3 clusters."
echo "    Verify K8s secrets exist:"
echo "      kubectl get secret rds-credentials -n petclinic-linkerd"
echo "      kubectl get secret openai-api-key  -n petclinic-linkerd"
