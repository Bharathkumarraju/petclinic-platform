#!/usr/bin/env bash
# Install Linkerd service mesh on petclinic-linkerd EKS cluster.
# Uses Helm charts (linkerd-crds + linkerd-control-plane + linkerd-viz).
# Generates a trust anchor and issuer cert with `step` CLI.
# After install, restarts pods in petclinic-linkerd namespace to inject proxies.
set -euo pipefail

CONTEXT="petclinic-linkerd"
LINKERD_NS="linkerd"
VIZ_NS="linkerd-viz"
APP_NS="petclinic-linkerd"

CRDS_VERSION="1.8.0"
CP_VERSION="1.16.11"
VIZ_VERSION="30.12.11"

CERT_DIR="$(mktemp -d)"
trap 'rm -rf "${CERT_DIR}"' EXIT

echo "════════════════════════════════════════════════════════"
echo "  Installing Linkerd on cluster: ${CONTEXT}"
echo "════════════════════════════════════════════════════════"

# ── 1. Generate TLS certificates ────────────────────────────────────────────
echo ""
echo "[1/6] Generating trust anchor and issuer certificates"

step certificate create \
  root.linkerd.cluster.local \
  "${CERT_DIR}/ca.crt" "${CERT_DIR}/ca.key" \
  --profile root-ca \
  --no-password --insecure \
  --not-after 87600h 2>/dev/null

step certificate create \
  identity.linkerd.cluster.local \
  "${CERT_DIR}/issuer.crt" "${CERT_DIR}/issuer.key" \
  --profile intermediate-ca \
  --not-after 8760h \
  --no-password --insecure \
  --ca "${CERT_DIR}/ca.crt" \
  --ca-key "${CERT_DIR}/ca.key" 2>/dev/null

echo "    Trust anchor and issuer certs generated."

# ── 2. Create linkerd namespace ──────────────────────────────────────────────
echo ""
echo "[2/6] Creating namespace: ${LINKERD_NS}"
kubectl --context="${CONTEXT}" create namespace "${LINKERD_NS}" --dry-run=client -o yaml | \
  kubectl --context="${CONTEXT}" apply -f -

# ── 3. Install linkerd-crds ─────────────────────────────────────────────────
echo ""
echo "[3/6] Installing linkerd-crds (chart ${CRDS_VERSION})"
helm upgrade --install linkerd-crds linkerd/linkerd-crds \
  --kube-context "${CONTEXT}" \
  --namespace "${LINKERD_NS}" \
  --version "${CRDS_VERSION}" \
  --wait --timeout 5m

# ── 4. Install linkerd-control-plane ────────────────────────────────────────
echo ""
echo "[4/6] Installing linkerd-control-plane (chart ${CP_VERSION})"
helm upgrade --install linkerd-control-plane linkerd/linkerd-control-plane \
  --kube-context "${CONTEXT}" \
  --namespace "${LINKERD_NS}" \
  --version "${CP_VERSION}" \
  --set-file identityTrustAnchorsPEM="${CERT_DIR}/ca.crt" \
  --set-file identity.issuer.tls.crtPEM="${CERT_DIR}/issuer.crt" \
  --set-file identity.issuer.tls.keyPEM="${CERT_DIR}/issuer.key" \
  --wait --timeout 10m

# ── 5. Install linkerd-viz ───────────────────────────────────────────────────
echo ""
echo "[5/6] Installing linkerd-viz (chart ${VIZ_VERSION})"
kubectl --context="${CONTEXT}" create namespace "${VIZ_NS}" --dry-run=client -o yaml | \
  kubectl --context="${CONTEXT}" apply -f -

helm upgrade --install linkerd-viz linkerd/linkerd-viz \
  --kube-context "${CONTEXT}" \
  --namespace "${VIZ_NS}" \
  --version "${VIZ_VERSION}" \
  --set tap.enabled=true \
  --wait --timeout 10m

# ── 6. Restart app pods to inject Linkerd proxies ───────────────────────────
echo ""
echo "[6/6] Restarting deployments in ${APP_NS} to inject Linkerd proxies"
kubectl --context="${CONTEXT}" rollout restart deployment \
  --namespace="${APP_NS}"

echo "    Waiting for rollouts to complete..."
kubectl --context="${CONTEXT}" rollout status deployment \
  --namespace="${APP_NS}" \
  --timeout=300s 2>/dev/null || true

# ── Verify ───────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
echo "  Linkerd installation complete. Verifying..."
echo "════════════════════════════════════════════════════════"

echo ""
echo "Control plane pods:"
kubectl --context="${CONTEXT}" get pods -n "${LINKERD_NS}" 2>&1

echo ""
echo "Viz pods:"
kubectl --context="${CONTEXT}" get pods -n "${VIZ_NS}" 2>&1

echo ""
echo "App pods (should show 2/2 READY with proxy injected):"
kubectl --context="${CONTEXT}" get pods -n "${APP_NS}" 2>&1

echo ""
echo "  Port-forward to access Linkerd dashboard:"
echo "  kubectl port-forward svc/web 8084:8084 -n ${VIZ_NS} --context ${CONTEXT}"
