#!/usr/bin/env bash
# Authenticate Docker to the shared ECR private registry in eu-central-1.
# Run this before any docker build/push to ECR. Tokens expire after 12 hours.
#
# Usage: ./scripts/ecr-login.sh [--region eu-central-1]

set -euo pipefail

REGION="eu-central-1"

while [[ $# -gt 0 ]]; do
  case $1 in
    --region) REGION="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--region eu-central-1]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo "==> Logging in to ECR: ${REGISTRY}"
aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"
echo "[ok] Docker authenticated to ${REGISTRY} (token valid 12h)"
