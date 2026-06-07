#!/usr/bin/env bash
# Install AWS Load Balancer Controller on all 3 EKS clusters.
# Prerequisites: aws CLI, helm, kubectl configured, terraform outputs available.
# Run after: terraform apply for shared + all 3 cluster environments.

set -euo pipefail

REGION="eu-central-1"
ACCOUNT_ID="172586632398"
LBC_VERSION="1.11.0"

CLUSTERS=(
  "petclinic-linkerd:linkerd"
  "petclinic-istio:istio"
  "petclinic-cilium:cilium"
)

install_lbc() {
  local cluster_name="$1"
  local env="$2"

  echo ""
  echo "==> Installing AWS LBC on ${cluster_name} (env=${env})"

  # Update kubeconfig
  aws eks update-kubeconfig \
    --region "${REGION}" \
    --name "${cluster_name}" \
    --alias "${cluster_name}"

  # Get IRSA role ARN from Terraform output
  local role_arn
  role_arn=$(terraform -chdir="$(dirname "$0")/../terraform/environments/${env}" \
    output -raw lb_controller_role_arn)

  echo "    IRSA role: ${role_arn}"

  # Add the eks-charts Helm repo
  helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
  helm repo update eks

  # Install / upgrade the controller
  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --namespace kube-system \
    --kube-context "${cluster_name}" \
    --set clusterName="${cluster_name}" \
    --set serviceAccount.create=true \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${role_arn}" \
    --set region="${REGION}" \
    --set vpcId="$(terraform -chdir="$(dirname "$0")/../terraform/environments/shared" output -raw vpc_id)" \
    --set image.repository="602401143452.dkr.ecr.${REGION}.amazonaws.com/amazon/aws-load-balancer-controller" \
    --version "${LBC_VERSION}" \
    --wait \
    --timeout 5m

  echo "    LBC installed on ${cluster_name}"
}

for entry in "${CLUSTERS[@]}"; do
  cluster="${entry%%:*}"
  env="${entry##*:}"
  install_lbc "${cluster}" "${env}"
done

echo ""
echo "==> AWS Load Balancer Controller installed on all 3 clusters."
echo "    Next: run scripts/apply-ingress.sh to deploy the Ingress resources."
