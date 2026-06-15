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

Linkerd is a **sidecar-based** service mesh — every application pod gets an additional `linkerd-proxy` container injected automatically. This means every pod runs **2/2** containers (app + proxy). The proxy is written in Rust and is the lowest-latency sidecar among mainstream service meshes, but the sidecar model has a real cost: memory overhead per pod, additional container restarts on upgrades, and iptables-based traffic interception on every node.

> **Key limitation vs Istio Ambient and Cilium:** Linkerd always requires a sidecar proxy per pod. There is no ambient or eBPF mode. On this platform (8 services × 2 replicas = 16 pods), that means 16 additional `linkerd-proxy` containers consuming ~20–50 MB each.

Linkerd ships as **two separate Helm charts** installed into two separate namespaces — this is intentional, not an accident:

| Namespace | Chart | Role | Required? |
|-----------|-------|------|-----------|
| `linkerd` | `linkerd-crds` + `linkerd-control-plane` | **The mesh** — identity (CA), destination (service discovery), proxy-injector (mutating webhook). Makes mTLS and traffic encryption work. | Yes |
| `linkerd-viz` | `linkerd-viz` | **Observability dashboard** — web UI, tap (live traffic inspection), tap-injector, metrics-api, bundled Prometheus. | Optional |

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
# The proxy-injector webhook injects linkerd-proxy into pods on namespace
# annotated with linkerd.io/inject: enabled. Existing pods need a rollout restart.
kubectl rollout restart deployment -n petclinic-linkerd
```

Full script: `scripts/install-linkerd.sh`

### Control plane components

```
namespace: linkerd          ← THE MESH (always required)
├── linkerd-destination     (service discovery, load balancing, endpoint resolution)
│                            runs 4/4 — includes sp-validator, policy-controller + proxy
├── linkerd-identity        (certificate authority — issues mTLS certs to proxies; 2/2)
├── linkerd-proxy-injector  (mutating webhook — injects linkerd-proxy sidecar on pod create; 2/2)
└── linkerd-heartbeat       (CronJob — phones home to buoyant.io with cluster stats)

Services in linkerd namespace:
  linkerd-dst               (destination controller gRPC endpoint)
  linkerd-dst-headless      (headless variant for direct proxy connections)
  linkerd-identity          (identity gRPC — proxies exchange certs here)
  linkerd-policy            (policy controller endpoint)
  linkerd-policy-validator  (admission webhook for Server/AuthorizationPolicy CRDs)
  linkerd-proxy-injector    (mutating webhook endpoint)
  linkerd-sp-validator      (ServiceProfile CRD validation webhook)

namespace: linkerd-viz      ← OBSERVABILITY (optional, not needed for mesh to function)
├── web                     (dashboard UI; 2/2)
├── tap                     (live traffic inspection — streams request/response metadata; 2/2)
├── tap-injector            (mutating webhook — injects tap headers into proxied requests; 2/2)
├── metrics-api             (aggregates Prometheus data for dashboard; 2/2)
└── prometheus              (bundled Prometheus scraping mesh metrics; 2/2)
```

### Running state (live cluster output)

```
$ kubectl get all -n linkerd --context petclinic-linkerd

NAME                                      READY   STATUS    RESTARTS   AGE
pod/linkerd-destination-xxxxxxxxx-xxxxx   4/4     Running   0          2d
pod/linkerd-identity-xxxxxxxxx-xxxxx      2/2     Running   0          2d
pod/linkerd-proxy-injector-xxxxxxx-xxxxx  2/2     Running   0          2d

NAME                              TYPE        CLUSTER-IP   PORT(S)
service/linkerd-dst               ClusterIP   10.x.x.x     8086/TCP
service/linkerd-dst-headless      ClusterIP   None         8086/TCP
service/linkerd-identity          ClusterIP   10.x.x.x     8080/TCP
service/linkerd-policy            ClusterIP   10.x.x.x     8090/TCP
service/linkerd-policy-validator  ClusterIP   10.x.x.x     443/TCP
service/linkerd-proxy-injector    ClusterIP   10.x.x.x     443/TCP
service/linkerd-sp-validator      ClusterIP   10.x.x.x     443/TCP

NAME                                                SCHEDULE      SUSPEND   ACTIVE
cronjob.batch/linkerd-heartbeat                     0 6 * * *     False     0
```

```
$ kubectl get all -n linkerd-viz --context petclinic-linkerd

NAME                                     READY   STATUS    RESTARTS   AGE
pod/metrics-api-xxxxxxxxx-xxxxx          2/2     Running   0          2d
pod/prometheus-xxxxxxxxx-xxxxx           2/2     Running   0          2d
pod/tap-xxxxxxxxx-xxxxx                  2/2     Running   0          2d
pod/tap-injector-xxxxxxxxx-xxxxx         2/2     Running   0          2d
pod/web-xxxxxxxxx-xxxxx                  2/2     Running   0          2d
```

```
$ kubectl get pods -n petclinic-linkerd --context petclinic-linkerd

NAME                                 READY   STATUS    RESTARTS   AGE
admin-server-xxxxxxxxx-xxxxx         2/2     Running   0          2d
api-gateway-xxxxxxxxx-xxxxx          2/2     Running   0          2d
config-server-xxxxxxxxx-xxxxx        2/2     Running   0          2d
customers-service-xxxxxxxxx-xxxxx    2/2     Running   0          2d
discovery-server-xxxxxxxxx-xxxxx     2/2     Running   0          2d
genai-service-xxxxxxxxx-xxxxx        2/2     Running   0          2d
vets-service-xxxxxxxxx-xxxxx         2/2     Running   0          2d
visits-service-xxxxxxxxx-xxxxx       2/2     Running   0          2d
```

All 8 services show **2/2 READY** — one app container and one `linkerd-proxy` sidecar per pod.

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

# Zipkin
kubectl port-forward svc/zipkin 9411:9411 -n tracing --context petclinic-linkerd
# Open: http://localhost:9411
```

### Sidecar injection: namespace label vs pod annotation

The `proxy-injector` mutating webhook checks for `linkerd.io/inject: enabled` on either the **namespace** or the **pod template** — whichever is present. Both work identically.

| Approach | Where set | How |
|----------|-----------|-----|
| Namespace label | `kubectl label namespace petclinic-linkerd linkerd.io/inject=enabled` | Injects every pod in that namespace automatically — no per-manifest change needed |
| Pod annotation | `podAnnotations: linkerd.io/inject: enabled` in Helm values / pod spec | Injects only pods that carry the annotation — namespace needs no label |

**This POC uses pod-level annotation** (`helm-values/linkerd.yaml`), not a namespace label. This is why `kubectl get ns petclinic-linkerd --show-labels` shows no Linkerd label, yet all pods are 2/2:

```yaml
# helm-values/linkerd.yaml
podAnnotations:
  linkerd.io/inject: enabled
```

Helm renders this into every Deployment's pod template:

```yaml
spec:
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled   # proxy-injector webhook fires on this
```

**Practical difference:** Pod-level annotation lets you opt out individual pods by setting `linkerd.io/inject: disabled` on them, even while everything else in the namespace is injected. Namespace-level label is simpler but less granular.

```bash
# Confirm injection annotation is set on pod templates (not namespace)
kubectl get pods -n petclinic-linkerd --context petclinic-linkerd \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.linkerd\.io/inject}{"\n"}{end}'

# Show all Linkerd-related annotations on every pod
kubectl get pods -n petclinic-linkerd --context petclinic-linkerd \
  -o json | jq -r '.items[] | .metadata.name + " → " + (.metadata.annotations | to_entries[] | select(.key | startswith("linkerd")) | .key + "=" + .value)'

# Confirm the namespace has NO Linkerd label (injection is pod-driven)
kubectl get ns petclinic-linkerd --show-labels --context petclinic-linkerd
```

### Verify injection

```bash
# App pods — all should show 2/2 READY (app + linkerd-proxy sidecar)
kubectl get pods -n petclinic-linkerd --context petclinic-linkerd

# Control plane — destination (4/4), identity (2/2), proxy-injector (2/2) + heartbeat cronjob
kubectl get all -n linkerd --context petclinic-linkerd

# Viz — web, tap, tap-injector, metrics-api, prometheus (all 2/2)
kubectl get all -n linkerd-viz --context petclinic-linkerd
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

### Installation mode used: CNI chaining (not full Cilium)

In this POC, Cilium runs **on top of AWS VPC CNI** in chaining mode — it does not replace it. `kube-proxy` is kept. Cilium adds network policy enforcement and Hubble observability on top of the existing VPC networking.

```bash
helm upgrade --install cilium cilium/cilium \
  -n kube-system --version 1.19.4 \
  --set cni.chainingMode=aws-cni \   # chain on top of VPC CNI, do not replace it
  --set cni.exclusive=false \
  --set routingMode=native \
  --set enableIPv4Masquerade=false \
  --set kubeProxyReplacement=false \ # keep kube-proxy
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}"
```

Full script: `scripts/install-cilium.sh`

### Why Cilium does not fit our use case

We are heavily invested in AWS VPC CNI and that is where the limitation surfaces. Cilium has two deployment modes, and the one that unlocks its full potential requires replacing the CNI entirely:

| Mode | What you get | What you give up |
|------|-------------|-----------------|
| **CNI chaining** (this POC) | Hubble observability, `CiliumNetworkPolicy`, eBPF-accelerated policy | No kube-proxy replacement, no Cilium IPAM, no WireGuard mTLS, no full eBPF service routing, limited L7 features |
| **Full Cilium CNI** (replace aws-node) | Everything above + kube-proxy replacement, Cilium IPAM, WireGuard transparent encryption, complete eBPF data plane | Must drain and re-provision nodes, lose AWS VPC CNI features (Security Groups for Pods, prefix delegation, VPC flow logs per-pod) |

**Specific AWS VPC CNI features we rely on that Cilium CNI replacement would break:**

- **Security Groups for Pods** (`aws-node` assigns ENIs so individual pods can have their own SG) — not supported when Cilium manages IPAM
- **VPC-native pod IPs** — AWS VPC CNI allocates IPs directly from the VPC subnet; Cilium uses its own IPAM pool which requires additional subnet planning
- **AWS-managed ENI lifecycle** — replacing `aws-node` means Cilium takes over ENI management, adding operational complexity on EKS
- **EKS managed add-ons** (`vpc-cni`, `kube-proxy`) — replacing these breaks the EKS managed upgrade path

**Bottom line:** To get real Cilium service mesh features (transparent mTLS via WireGuard, full eBPF networking), you have to commit to Cilium as your CNI from day one — it cannot be added non-disruptively to an existing VPC-CNI-based EKS cluster. Since our platform is built around AWS VPC CNI and EKS managed add-ons, Cilium is eliminated as a viable service mesh choice for this workload.

### What we do get in chaining mode (POC only)

Even in chaining mode, Hubble provides genuinely useful visibility:

```
namespace: kube-system
├── cilium                  (DaemonSet — eBPF agent, policy enforcement)
├── cilium-envoy            (DaemonSet — L7 proxy for HTTP-level CiliumNetworkPolicy)
├── cilium-operator         (manages CiliumNetworkPolicy, health)
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
