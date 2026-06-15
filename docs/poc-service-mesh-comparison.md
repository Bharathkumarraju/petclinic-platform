# POC: Service Mesh Comparison — Linkerd vs Istio Ambient vs Cilium

## Goal

Evaluate three leading open-source service meshes on a real microservices workload to identify the best fit for production adoption.

**Decision criteria:**
- **Cost** — control-plane overhead, sidecar memory tax, node count impact
- **Community & longevity** — CNCF graduation status, release cadence, ecosystem
- **Operational simplicity** — installation, upgrade path, debugging tooling

**Outcome:** We are adopting **Istio Ambient Mode** — it eliminates per-pod sidecar overhead (cost), is a CNCF graduated project with the largest contributor base, and its ambient architecture is the direction the industry is moving toward.

---

## Platform Architecture

One shared VPC, three independent EKS clusters — each running the **identical** workload so comparisons are apples-to-apples.

```
AWS eu-central-1
└── VPC: 10.0.0.0/16
    ├── EKS: petclinic-linkerd   (Linkerd 1.16)
    ├── EKS: petclinic-istio     (Istio Ambient 1.30)
    └── EKS: petclinic-cilium    (Cilium 1.19, CNI chaining)

Shared across all clusters:
    ├── RDS MySQL 8.0  (petclinic-shared-mysql)
    └── ECR            (petclinic/{service}:{sha})
```

### Infrastructure (brief)

| Component | Detail |
|-----------|--------|
| **VPC** | Single VPC, public subnets only (SGs as perimeter — cost optimised, no NAT gateway) |
| **EKS** | Kubernetes 1.33, 8× t4g.small ARM nodes per cluster, managed node groups |
| **ECR** | One shared registry, all 3 clusters pull the same images (`petclinic/{service}:{sha}`) |
| **RDS** | `db.t4g.micro` MySQL 8.0, shared across all 3 clusters, HikariCP pool capped at 2 per service |
| **Observability** | kube-prometheus-stack + Loki + FluentBit + Zipkin on every cluster |

---

## Application: Spring Petclinic Microservices

Source: https://github.com/spring-petclinic/spring-petclinic-microservices

Eight Spring Boot 3 services deployed on every cluster:

| Service | Port | Role |
|---------|------|------|
| config-server | 8888 | Git-backed centralised config (starts first) |
| discovery-server | 8761 | Eureka service registry (starts second) |
| api-gateway | 8080 | Spring Cloud Gateway — public entry point |
| customers-service | 8081 | Owners & pets (MySQL) |
| visits-service | 8082 | Visit records (MySQL) |
| vets-service | 8083 | Vet data, Caffeine cache (MySQL) |
| genai-service | 8084 | AI assistant (OpenAI) |
| admin-server | 9090 | Spring Boot Admin dashboard |

**Live endpoints:**

| Cluster | URL |
|---------|-----|
| Linkerd | https://petclinic-linkerd.kube-hub.com/ |
| Istio Ambient | https://petclinic-istio.kube-hub.com/ |
| Cilium | https://petclinic-cilium.kube-hub.com/ |

---

## Service Mesh Comparison

### Architecture at a glance

| | Linkerd | Istio Ambient | Cilium |
|---|---|---|---|
| **Data plane** | Sidecar proxy per pod (linkerd-proxy) | ztunnel per node (L4) + waypoint per namespace (L7) | eBPF programs in the kernel |
| **Pod containers** | **2/2** (app + proxy) | **1/1** (no sidecar) | **1/1** (no sidecar) |
| **mTLS** | Proxy-to-proxy | ztunnel-to-ztunnel | WireGuard / IPsec (kernel) |
| **L7 observability** | Built into proxy | Waypoint proxy (opt-in) | Hubble (eBPF kernel reads) |
| **Memory overhead** | ~20–50 MB per pod | ~50 MB per node (ztunnel) | Minimal — no userspace proxy |
| **CNI** | Runs alongside any CNI | Runs alongside any CNI | Chained on top of VPC CNI |
| **kube-proxy replacement** | No | No | Optional (disabled in this POC) |
| **CNCF status** | Graduated | Graduated | Graduated |

---

## Linkerd

### What it is
The original lightweight sidecar mesh. Written in Rust (linkerd-proxy), lowest latency overhead among sidecar-based meshes. Extremely simple to operate.

Linkerd ships as **two separate Helm charts** installed into two separate namespaces — this is intentional, not an accident:

| Namespace | Chart | Role | Required? |
|-----------|-------|------|-----------|
| `linkerd` | `linkerd-crds` + `linkerd-control-plane` | **The mesh** — identity (CA), destination (service discovery), proxy-injector (mutating webhook). Makes mTLS and traffic encryption work. | Yes |
| `linkerd-viz` | `linkerd-viz` | **Observability dashboard** — web UI, tap (live traffic inspection), metrics-api, bundled Prometheus. | Optional |

**Why split?** The control plane is security-critical and must be minimal. `linkerd-viz` adds a web server, a full Prometheus, and `tap` (which can read live request payloads) — you may not want that in a locked-down production cluster. Many teams run the control plane everywhere but only install viz in staging for debugging, relying on their own Prometheus/Grafana stack in production.

### Installation

```bash
# Step 1: Generate trust anchor (root CA) and issuer certs via step CLI
step certificate create root.linkerd.cluster.local ca.crt ca.key \
  --profile root-ca --no-password --insecure --not-after 87600h

step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
  --profile intermediate-ca --not-after 8760h --no-password --insecure \
  --ca ca.crt --ca-key ca.key

# Step 2: Install CRDs
helm upgrade --install linkerd-crds linkerd/linkerd-crds \
  -n linkerd --create-namespace --version 1.8.0

# Step 3: Install control plane (the mesh)
helm upgrade --install linkerd-control-plane linkerd/linkerd-control-plane \
  -n linkerd --version 1.16.11 \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key

# Step 4: Install viz dashboard (optional but used in this POC)
helm upgrade --install linkerd-viz linkerd/linkerd-viz \
  -n linkerd-viz --create-namespace --version 30.12.11

# Step 5: Inject proxies by restarting app pods
kubectl rollout restart deployment -n petclinic-linkerd
```

Full script: `scripts/install-linkerd.sh`

### Control plane components

```
namespace: linkerd          ← THE MESH (always required)
├── linkerd-destination     (service discovery, load balancing, endpoint resolution)
├── linkerd-identity        (certificate authority — issues mTLS certs to proxies)
└── linkerd-proxy-injector  (mutating webhook — injects linkerd-proxy sidecar on pod create)

namespace: linkerd-viz      ← OBSERVABILITY (optional, not needed for mesh to function)
├── web                     (dashboard UI)
├── tap                     (live traffic inspection — streams request/response metadata)
├── metrics-api             (aggregates Prometheus data for dashboard)
└── prometheus              (bundled Prometheus scraping mesh metrics)
```

### How it works in this POC

Every pod in `petclinic-linkerd` runs **2/2** containers — the app and the `linkerd-proxy` sidecar. The `proxy-injector` webhook automatically injects the proxy when a pod is created in a namespace annotated with `linkerd.io/inject: enabled`. The proxy intercepts all inbound and outbound TCP via iptables, terminates/originates mTLS, and emits golden-signal metrics (latency, RPS, success rate) to Prometheus.

```
Pod (2/2):
├── app container          (Spring Boot service)
└── linkerd-proxy          (Rust proxy — handles all TCP in/out, mTLS, metrics)
```

### Access

```bash
# Linkerd dashboard (linkerd-viz)
kubectl port-forward svc/web 8084:8084 -n linkerd-viz --context petclinic-linkerd
# Open: http://localhost:8084

# Grafana (kube-prometheus-stack)
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring --context petclinic-linkerd
# Open: http://localhost:3000  (admin / petclinic-grafana)
```

### Verify injection

```bash
kubectl get pods -n petclinic-linkerd --context petclinic-linkerd
# All pods should show 2/2 READY (app + linkerd-proxy)

kubectl get pods -n linkerd --context petclinic-linkerd
# Control plane: destination, identity, proxy-injector

kubectl get pods -n linkerd-viz --context petclinic-linkerd
# Viz: web, tap, tap-injector, metrics-api, prometheus
```

---

## Istio Ambient Mode

### What it is
Istio's new sidecar-free architecture (GA in Istio 1.22). Traffic is intercepted at the **node level** by ztunnel (a Rust-based per-node DaemonSet) rather than per-pod. L7 features (HTTP routing, JWT, header-based policies) are handled by an optional **waypoint proxy** deployed per namespace.

### Why we chose this

| Reason | Detail |
|--------|--------|
| **No sidecar tax** | Eliminates ~20–50 MB per pod memory overhead — on 8 services × 3 replicas = meaningful savings |
| **CNCF Graduated** | Largest service mesh contributor community; ambient is the official Istio roadmap |
| **Incremental L7** | Start with L4 mTLS (free via ztunnel), add waypoint only when L7 policy is needed |
| **Gateway API native** | Built on Kubernetes Gateway API standard — no Istio-specific CRDs for routing |
| **Ecosystem** | Best-in-class integrations: Kiali, Jaeger, Prometheus, Grafana, ArgoCD |

### Installation

```bash
# 1. Gateway API CRDs (required for waypoint)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml

# 2. Istio base CRDs
helm upgrade --install istio-base istio/base -n istio-system --version 1.30.1

# 3. istiod (control plane)
helm upgrade --install istiod istio/istiod -n istio-system --version 1.30.1 --set profile=ambient

# 4. istio-cni (DaemonSet — configures iptables rules for ambient interception)
helm upgrade --install istio-cni istio/cni -n istio-system --version 1.30.1 --set profile=ambient

# 5. ztunnel (DaemonSet — per-node L4 proxy handling mTLS)
helm upgrade --install ztunnel istio/ztunnel -n istio-system --version 1.30.1

# 6. Enroll namespace + deploy waypoint (L7)
kubectl label namespace petclinic-istio istio.io/dataplane-mode=ambient
istioctl waypoint apply --context petclinic-istio -n petclinic-istio
kubectl label namespace petclinic-istio istio.io/use-waypoint=waypoint
```

Full script: `scripts/install-istio-ambient.sh`

### Control plane components

```
namespace: istio-system
├── istiod                  (control plane: xDS config push, CA, certificate issuance)
├── istio-cni-node          (DaemonSet on every node — sets up iptables for interception)
└── ztunnel                 (DaemonSet on every node — L4 mTLS proxy, HBONE tunnel)

namespace: petclinic-istio
└── waypoint                (Envoy-based L7 proxy, 1 per namespace — handles HTTP policy)
```

### Traffic flow

```
Pod A  →  ztunnel (node A)  ──HBONE/mTLS──►  ztunnel (node B)  →  Pod B
                                    ↓ (if L7 needed)
                              waypoint proxy
                         (AuthorizationPolicy, JWT, HTTPRoute)
```

### Access

```bash
# Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring --context petclinic-istio
# Open: http://localhost:3000

# Zipkin (distributed tracing)
kubectl port-forward svc/zipkin 9411:9411 -n tracing --context petclinic-istio
# Open: http://localhost:9411
```

### Verify ambient enrollment

```bash
# All pods should show "enabled"
kubectl get pods -n petclinic-istio --context petclinic-istio \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.ambient\.istio\.io/redirection}{"\n"}{end}'

# Waypoint should be Programmed=True
kubectl get gateway -n petclinic-istio --context petclinic-istio
```

---

## Cilium

### What it is
A CNI plugin and service mesh built entirely on **eBPF** — Linux kernel technology that lets Cilium attach programmable hooks at the kernel networking layer without any userspace proxy. Includes Hubble for deep network observability.

### How it differs
There is **no proxy process** at all — neither sidecar nor node-level daemon handles L4/L7 traffic in userspace. eBPF programs run inside the kernel itself, making Cilium the lowest-overhead option for raw packet processing.

### Installation (CNI chaining mode)

Installed on top of the existing AWS VPC CNI without replacing it — `kube-proxy` is kept. Cilium adds network policy enforcement and Hubble observability.

```bash
helm upgrade --install cilium cilium/cilium \
  -n kube-system --version 1.19.4 \
  --set cni.chainingMode=aws-cni \
  --set cni.exclusive=false \
  --set routingMode=native \
  --set enableIPv4Masquerade=false \
  --set kubeProxyReplacement=false \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}"
```

Full script: `scripts/install-cilium.sh`

### Components

```
namespace: kube-system
├── cilium                  (DaemonSet — eBPF agent on every node)
├── cilium-envoy            (DaemonSet — L7 proxy for HTTP-level policy)
├── cilium-operator         (manages CiliumNetworkPolicy, IPAM)
├── hubble-relay            (aggregates flow data from all nodes)
└── hubble-ui               (web UI — real-time network flow visualisation)
```

### Access

```bash
# Hubble UI (network flow visualisation)
kubectl port-forward svc/hubble-ui 12000:80 -n kube-system --context petclinic-cilium
# Open: http://localhost:12000  → select namespace: petclinic-cilium

# Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring --context petclinic-cilium
# Open: http://localhost:3000
```

---

## Observability Stack (all clusters)

Each cluster runs the same observability stack:

| Tool | Namespace | Purpose |
|------|-----------|---------|
| Prometheus (kube-prometheus-stack) | monitoring | Metrics scraping, alerting |
| Grafana | monitoring | Dashboards (JVM, Spring Boot, Kubernetes pods) |
| Loki + FluentBit | monitoring | Log aggregation from all pods |
| Zipkin | tracing | Distributed request tracing |
| Alertmanager | monitoring | Alert routing |

**Tracing note:** Spring Boot services send traces to `tracing-server:9411` (an ExternalName service aliasing `zipkin.tracing.svc.cluster.local`) — this matches the hostname in the upstream spring-petclinic-microservices-config repo.

---

## Decision Summary: Istio Ambient Mode

| Criterion | Linkerd | Istio Ambient | Cilium |
|-----------|---------|---------------|--------|
| **Memory per pod** | +20–50 MB (sidecar) | **0 MB** (no sidecar) | **0 MB** (eBPF) |
| **CPU overhead** | Medium | Low | Lowest |
| **mTLS** | ✅ Automatic | ✅ Automatic | ✅ WireGuard (kernel) |
| **L7 policy** | ✅ Full | ✅ Via waypoint | ⚠️ Limited in chaining mode |
| **Distributed tracing** | ✅ | ✅ | ⚠️ Hubble only (no Zipkin integration) |
| **CNCF Graduated** | ✅ | ✅ | ✅ |
| **Community size** | Medium | **Largest** | Large |
| **Upgrade complexity** | Low | Medium | Low |
| **Best for** | Simple sidecar mesh | **Production scale, cost-sensitive** | Pure networking/policy |

### Why Istio Ambient

1. **Cost** — removing sidecars from 8 services × N replicas × 3 clusters saves meaningful memory at scale; on `t4g.small` nodes (~1.5 Gi allocatable) this directly reduces node count needed
2. **Community** — Istio has the broadest vendor support (Google, Red Hat, Solo.io, Tetrate), largest contributor base, and fastest release cycle among the three
3. **Flexibility** — start with L4 mTLS at zero overhead; add waypoint per-namespace only when L7 AuthorizationPolicy or traffic management is needed
4. **Gateway API alignment** — Istio Ambient is fully built on the Kubernetes Gateway API standard — no vendor lock-in on routing CRDs
5. **Ecosystem** — best-in-class support in ArgoCD, Kiali, Jaeger, and all major Kubernetes tooling

---

## Repository

All infrastructure code: https://github.com/Bharathkumarraju/petclinic-platform

```
terraform/environments/{shared,linkerd,istio,cilium}/   # IaC
helm/petclinic-service/                                  # Generic Helm chart
helm-values/                                             # Per-service + per-mesh values
scripts/install-{linkerd,istio-ambient,cilium}.sh        # Mesh install scripts
k8s/base/observability/                                  # Zipkin, alert rules
helm-values/monitoring/                                  # Prometheus, Grafana, Loki, FluentBit
```
