#!/usr/bin/env bash
# Create Route53 CNAME records for each cluster's ALB.
# Reads ALB hostnames from kubectl and upserts records in the kube-hub.com zone.
# Run AFTER apply-ingress.sh and ALBs are fully provisioned.
# Prerequisites: aws CLI, kubectl, jq.

set -euo pipefail

REGION="eu-central-1"
HOSTED_ZONE_ID="Z0544616200CRHX1P2OAX"
DOMAIN="kube-hub.com"
TTL=60

MESHES=(
  "linkerd:petclinic-linkerd:petclinic-linkerd:petclinic-linkerd.${DOMAIN}"
  "istio:petclinic-istio:petclinic-istio:petclinic-istio.${DOMAIN}"
  "cilium:petclinic-cilium:petclinic-cilium:petclinic-cilium.${DOMAIN}"
)

upsert_cname() {
  local cluster_name="$1"
  local namespace="$2"
  local hostname="$3"

  echo ""
  echo "==> Fetching ALB hostname for ${cluster_name}"

  local alb_hostname
  alb_hostname=$(kubectl --context="${cluster_name}" get ingress petclinic-ingress \
    --namespace="${namespace}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

  if [[ -z "${alb_hostname}" ]]; then
    echo "    WARNING: ALB hostname not yet available for ${cluster_name}. Skipping."
    return
  fi

  echo "    ALB: ${alb_hostname}"
  echo "    Route53: ${hostname} -> ${alb_hostname}"

  aws route53 change-resource-record-sets \
    --hosted-zone-id "${HOSTED_ZONE_ID}" \
    --change-batch "$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${hostname}",
        "Type": "CNAME",
        "TTL": ${TTL},
        "ResourceRecords": [
          { "Value": "${alb_hostname}" }
        ]
      }
    }
  ]
}
EOF
)"

  echo "    Record upserted: ${hostname} CNAME ${alb_hostname}"
}

for entry in "${MESHES[@]}"; do
  IFS=':' read -r mesh cluster ns fqdn <<< "${entry}"

  # Ensure kubeconfig is current
  aws eks update-kubeconfig \
    --region "${REGION}" \
    --name "${cluster}" \
    --alias "${cluster}" 2>/dev/null

  upsert_cname "${cluster}" "${ns}" "${fqdn}"
done

echo ""
echo "==> DNS records updated."
echo "    Verify with:"
echo "      dig petclinic-linkerd.kube-hub.com"
echo "      dig petclinic-istio.kube-hub.com"
echo "      dig petclinic-cilium.kube-hub.com"
