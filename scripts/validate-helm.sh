#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHART="${REPO_ROOT}/helm/petclinic-service"
VALUES_DIR="${REPO_ROOT}/helm-values"

SERVICES=(config-server discovery-server api-gateway customers-service visits-service vets-service genai-service admin-server)
MESHES=(linkerd istio cilium)

# Filters — override with --service <name> or --mesh <name>
FILTER_SERVICE=""
FILTER_MESH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --service) FILTER_SERVICE="$2"; shift 2 ;;
    --mesh)    FILTER_MESH="$2";    shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

pass=0; fail=0

run_check() {
  local label="$1"; shift
  if "$@" > /dev/null 2>&1; then
    echo "  PASS  $label"
    pass=$((pass + 1))
  else
    echo "  FAIL  $label"
    "$@" 2>&1 | sed 's/^/        /'
    fail=$((fail + 1))
  fi
}

echo "=== Step 1: helm lint ==="
run_check "helm lint" helm lint "${CHART}" --quiet

echo ""
echo "=== Step 2: helm template + Step 3: kubectl dry-run (24 combinations) ==="

for svc in "${SERVICES[@]}"; do
  [[ -n "${FILTER_SERVICE}" && "${svc}" != "${FILTER_SERVICE}" ]] && continue
  for mesh in "${MESHES[@]}"; do
    [[ -n "${FILTER_MESH}" && "${mesh}" != "${FILTER_MESH}" ]] && continue
    ns="petclinic-${mesh}"
    release="${svc}-${mesh}"
    label="${svc}/${mesh}"

    # Step 2: template renders without error
    run_check "template  ${label}" \
      helm template "${release}" "${CHART}" \
        -f "${VALUES_DIR}/${svc}.yaml" \
        -f "${VALUES_DIR}/${mesh}.yaml" \
        --namespace "${ns}"

    # Step 3: dry-run against live cluster
    run_check "dry-run   ${label}" bash -c \
      "helm template '${release}' '${CHART}' \
        -f '${VALUES_DIR}/${svc}.yaml' \
        -f '${VALUES_DIR}/${mesh}.yaml' \
        --namespace '${ns}' | \
       kubectl apply --dry-run=client -f - --namespace '${ns}'"
  done
done

echo ""
total=$((pass + fail))
echo "=== Results: ${pass}/${total} passed ==="
[[ $fail -gt 0 ]] && exit 1 || exit 0
