#!/usr/bin/env bash
# Install Istio Ambient Mesh on petclinic-istio EKS cluster.
# Components: Gateway API CRDs → istio-base → istiod → istio-cni → ztunnel → waypoint
# Ambient mode: no sidecars; ztunnel handles mTLS at the node level (L4).
# Waypoint proxy handles L7 (HTTP headers, JWT, AuthorizationPolicy per service).
set -euo pipefail

CONTEXT="petclinic-istio"
ISTIO_NS="istio-system"
APP_NS="petclinic-istio"

ISTIO_VERSION="1.30.1"
GATEWAY_API_VERSION="v1.5.1"

echo "════════════════════════════════════════════════════════"
echo "  Installing Istio Ambient Mesh on cluster: ${CONTEXT}"
echo "  Istio: ${ISTIO_VERSION}  Gateway API: ${GATEWAY_API_VERSION}"
echo "════════════════════════════════════════════════════════"

# ── 1. Install Gateway API CRDs ─────────────────────────────────────────────
# Istio Ambient requires Gateway API CRDs for waypoint proxies (L7).
# Must be installed before istio-base so the GatewayClass CRD is present.
echo ""
echo "[1/7] Installing Gateway API CRDs (${GATEWAY_API_VERSION})"
kubectl --context="${CONTEXT}" apply -f \
  "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"
echo "    Gateway API CRDs installed."

# ── 2. Create istio-system namespace ────────────────────────────────────────
echo ""
echo "[2/7] Creating namespace: ${ISTIO_NS}"
kubectl --context="${CONTEXT}" create namespace "${ISTIO_NS}" --dry-run=client -o yaml | \
  kubectl --context="${CONTEXT}" apply -f -

# ── 3. Install istio-base (CRDs) ─────────────────────────────────────────────
echo ""
echo "[3/7] Installing istio/base (CRDs) — version ${ISTIO_VERSION}"
helm upgrade --install istio-base istio/base \
  --kube-context "${CONTEXT}" \
  --namespace "${ISTIO_NS}" \
  --version "${ISTIO_VERSION}" \
  --set defaultRevision=default \
  --wait --timeout 5m

# ── 4. Install istiod ────────────────────────────────────────────────────────
echo ""
echo "[4/7] Installing istiod — version ${ISTIO_VERSION}"
helm upgrade --install istiod istio/istiod \
  --kube-context "${CONTEXT}" \
  --namespace "${ISTIO_NS}" \
  --version "${ISTIO_VERSION}" \
  --set profile=ambient \
  --set pilot.resources.requests.cpu=100m \
  --set pilot.resources.requests.memory=256Mi \
  --set pilot.resources.limits.cpu=500m \
  --set pilot.resources.limits.memory=512Mi \
  --wait --timeout 10m

# ── 5. Install istio-cni (required for ambient mode) ────────────────────────
echo ""
echo "[5/7] Installing istio-cni — version ${ISTIO_VERSION}"
helm upgrade --install istio-cni istio/cni \
  --kube-context "${CONTEXT}" \
  --namespace "${ISTIO_NS}" \
  --version "${ISTIO_VERSION}" \
  --set profile=ambient \
  --set cni.ambient.enabled=true \
  --wait --timeout 10m

# ── 6. Install ztunnel (ambient L4 node proxy) ───────────────────────────────
echo ""
echo "[6/7] Installing ztunnel — version ${ISTIO_VERSION}"
helm upgrade --install ztunnel istio/ztunnel \
  --kube-context "${CONTEXT}" \
  --namespace "${ISTIO_NS}" \
  --version "${ISTIO_VERSION}" \
  --wait --timeout 10m

# ── 7. Enroll app namespace + deploy waypoint ────────────────────────────────
echo ""
echo "[7/7] Enrolling ${APP_NS} in ambient mesh and deploying waypoint proxy"

# Label namespace for ztunnel L4 interception
kubectl --context="${CONTEXT}" label namespace "${APP_NS}" \
  istio.io/dataplane-mode=ambient --overwrite

# Deploy waypoint proxy for L7 traffic (HTTP routing, AuthorizationPolicy, JWT)
# istioctl creates a Gateway resource with gatewayClassName=istio-waypoint
istioctl waypoint apply \
  --context="${CONTEXT}" \
  --namespace "${APP_NS}" \
  --wait

# Label namespace to route traffic through the waypoint
kubectl --context="${CONTEXT}" label namespace "${APP_NS}" \
  istio.io/use-waypoint=waypoint --overwrite

echo "    Waypoint proxy deployed and namespace enrolled."

# Restart app pods so ztunnel intercepts their traffic
echo ""
echo "  Restarting ${APP_NS} pods for ambient enrollment..."
kubectl --context="${CONTEXT}" rollout restart deployment --namespace="${APP_NS}"
kubectl --context="${CONTEXT}" rollout status deployment --namespace="${APP_NS}" --timeout=300s 2>/dev/null || true

# ── Verify ───────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
echo "  Istio Ambient installation complete. Verifying..."
echo "════════════════════════════════════════════════════════"

echo ""
echo "Istio control plane pods:"
kubectl --context="${CONTEXT}" get pods -n "${ISTIO_NS}"

echo ""
echo "Waypoint proxy:"
kubectl --context="${CONTEXT}" get gateway -n "${APP_NS}"
kubectl --context="${CONTEXT}" get pods -n "${APP_NS}" -l gateway.istio.io/managed=istio.io-mesh-controller

echo ""
echo "App pods (ambient — 1/1, no sidecar):"
kubectl --context="${CONTEXT}" get pods -n "${APP_NS}"

echo ""
echo "Ambient enrollment (all pods should show 'enabled'):"
kubectl --context="${CONTEXT}" get pods -n "${APP_NS}" \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.ambient\.istio\.io/redirection}{"\n"}{end}'

echo ""
echo "Namespace labels:"
kubectl --context="${CONTEXT}" get namespace "${APP_NS}" --show-labels

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Port-forward commands:"
echo ""
echo "  Grafana:"
echo "  kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring --context ${CONTEXT}"
echo ""
echo "  Zipkin:"
echo "  kubectl port-forward svc/zipkin 9411:9411 -n tracing --context ${CONTEXT}"
echo "════════════════════════════════════════════════════════"
