#!/usr/bin/env bash
# Bootstrap Terraform remote state: S3 bucket with versioning, encryption, and public-access block.
# No DynamoDB — uses S3 native locking (use_lockfile = true in backends).
# Safe to run multiple times (idempotent).
#
# Usage: ./scripts/bootstrap-state.sh [--region eu-central-1] [--bucket petclinic-terraform-state]

set -euo pipefail

REGION="eu-central-1"
BUCKET="petclinic-terraform-state"

while [[ $# -gt 0 ]]; do
  case $1 in
    --region) REGION="$2"; shift 2 ;;
    --bucket) BUCKET="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

echo "==> Bootstrapping Terraform state bucket"
echo "    Bucket : s3://${BUCKET}"
echo "    Region : ${REGION}"
echo ""

# ── Create S3 bucket ──────────────────────────────────────────────────────
if aws s3api head-bucket --bucket "${BUCKET}" --region "${REGION}" 2>/dev/null; then
  echo "[ok] Bucket already exists: s3://${BUCKET}"
else
  echo "[..] Creating bucket s3://${BUCKET}"
  if [[ "${REGION}" == "us-east-1" ]]; then
    aws s3api create-bucket \
      --bucket "${BUCKET}" \
      --region "${REGION}"
  else
    aws s3api create-bucket \
      --bucket "${BUCKET}" \
      --region "${REGION}" \
      --create-bucket-configuration LocationConstraint="${REGION}"
  fi
  echo "[ok] Bucket created"
fi

# ── Block all public access ───────────────────────────────────────────────
echo "[..] Blocking all public access"
aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "[ok] Public access blocked"

# ── Enable versioning ─────────────────────────────────────────────────────
echo "[..] Enabling versioning"
aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled
echo "[ok] Versioning enabled"

# ── Enable SSE-S3 encryption ──────────────────────────────────────────────
echo "[..] Enabling default encryption (SSE-S3)"
aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }]
  }'
echo "[ok] Encryption enabled"

echo ""
echo "==> Done. Run terraform init in each environment directory:"
echo "    terraform/environments/shared/"
echo "    terraform/environments/linkerd/"
echo "    terraform/environments/istio/"
echo "    terraform/environments/cilium/"
