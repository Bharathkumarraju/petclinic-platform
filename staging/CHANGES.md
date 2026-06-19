# Service Mesh POC — Changes

## 2026-06-15 — Single-cluster migration + bookinfo deployment

### Infrastructure (Terraform)

**`terraform/environments/eks-servicemesh/main.tf`**
- Node groups scaled to reflect autoscaler state: `desired` 2→3, `max` 3→5 per group
- Autoscaler added a 3rd node to each group when bookinfo pods were pending during rollout

**`terraform/environments/eks-servicemesh/variables.tf`**
- Instance type: `t4g.small` → `t4g.medium`

**Cluster layout after apply — 9 nodes, 3 per mesh, spread across 2 AZs:**

| Node Group | Count | Node Label |
|---|---|---|
| eks-servicemesh-linkerd-nodes | 3 | `mesh=linkerd` |
| eks-servicemesh-istio-nodes | 3 | `mesh=istio` |
| eks-servicemesh-cilium-nodes | 3 | `mesh=cilium` |

---

### scripts/install-linkerd.sh

| Change | Before | After |
|---|---|---|
| `CONTEXT` | `petclinic-linkerd` | `eks-servicemesh` |
| `APP_NS` | `petclinic-linkerd` | `bookinfo-linkerd` |
| App source | petclinic (assumed pre-deployed) | bookinfo.yaml (istio/release-1.30) |

**Step 6 rewritten:**
1. Creates `bookinfo-linkerd` namespace
2. Annotates namespace `linkerd.io/inject=enabled` for auto proxy injection
3. Applies bookinfo.yaml
4. Patches all 6 deployments with `nodeSelector: {mesh: linkerd}`
5. Rollout restart triggers Linkerd proxy injection

**Live result:** 6 bookinfo pods `2/2 Running` — every pod has `linkerd-proxy` sidecar injected.

---

### scripts/install-istio-ambient.sh

| Change | Before | After |
|---|---|---|
| `CONTEXT` | `petclinic-istio` | `eks-servicemesh` |
| `APP_NS` | `petclinic-istio` | `bookinfo-istio` |
| App source | petclinic (assumed pre-deployed) | bookinfo.yaml (istio/release-1.30) |

**New Helm flags:**
- `istio-cni`: `--set nodeSelector.mesh=istio` — pins CNI DaemonSet to istio nodes only
- `ztunnel`: `--set nodeSelector.mesh=istio` — pins ztunnel DaemonSet to istio nodes only

**Step 7 rewritten:**
1. Creates `bookinfo-istio` namespace
2. Labels namespace `istio.io/dataplane-mode=ambient`
3. Applies bookinfo.yaml
4. Patches all 6 deployments with `nodeSelector: {mesh: istio}`
5. Deploys waypoint proxy via `istioctl waypoint apply`
6. Labels namespace `istio.io/use-waypoint=waypoint`
7. Rollout restart for ztunnel enrollment

**Post-deploy fix:** Waypoint pod landed on a cilium node (Gateway resource ignores namespace nodeSelector). Patched waypoint deployment with `nodeSelector: {mesh: istio}`.

**Live result:** 7 pods `1/1 Running` (no sidecars — sidecarless ambient mode), waypoint `Programmed=True`, ztunnel running only on istio nodes.

---

### scripts/install-cilium.sh

| Change | Before | After |
|---|---|---|
| `CONTEXT` | `petclinic-cilium` | `eks-servicemesh` |
| `CLUSTER_NAME` | `petclinic-cilium` | `eks-servicemesh` |
| `APP_NS` | — | `bookinfo-cilium` (new) |
| App source | none | bookinfo.yaml (istio/release-1.30) |

**New Helm flags:**
```
--set-json 'affinity={"nodeAffinity":...mesh=cilium...}'
--set-json 'envoy.affinity={"nodeAffinity":...mesh=cilium...}'
```
Both `cilium` and `cilium-envoy` DaemonSets pinned to `mesh=cilium` nodes.
First attempt used only `affinity` (missing `envoy.affinity`) — `cilium-envoy` tried all 9 nodes and timed out. Fixed in revision 2.

**Step 3 (new):** Creates `bookinfo-cilium` namespace → applies bookinfo.yaml → patches all 6 deployments with `nodeSelector: {mesh: cilium}`.

**Step 4 (new):** Applies 3 `CiliumNetworkPolicy` objects enforcing bookinfo call graph:

| Policy | Rule |
|---|---|
| `bookinfo-default-deny` | Allow traffic only within `bookinfo-cilium` namespace |
| `bookinfo-productpage-egress` | productpage → details, reviews |
| `bookinfo-reviews-egress` | reviews → ratings |

**Live result:** 6 bookinfo pods `1/1 Running` on cilium nodes, 3 CiliumNetworkPolicies `VALID`, Hubble relay + UI running.

---

### scripts/apply-istio-routing.sh (new)

Implements [Istio request routing](https://istio.io/latest/docs/tasks/traffic-management/request-routing/) for the `bookinfo-istio` namespace.

**Step 1 — DestinationRules:** Define version subsets for all 4 services (productpage, details, ratings, reviews) mapping subset names to pod label `version=vN`.

**Step 2 — Default route:** All traffic → `reviews-v1` (no star ratings).

**Step 3 — Header-based routing:** Overwrites the reviews VirtualService with two HTTP rules:

```
end-user: jason  →  reviews-v2  (black stars ★★★★★)
<everyone else>  →  reviews-v1  (no ratings)
```

**Verified from inside the cluster:**

| Request | Pod served | Response |
|---|---|---|
| No header | `reviews-v1-*` | No `rating` field |
| `end-user: jason` | `reviews-v2-*` | `"color": "black"`, stars 5/4 |
| `end-user: alice` | `reviews-v1-*` | No `rating` field |

L7 routing enforced by the waypoint proxy (not ztunnel). Zero sidecars involved.

---

### Final pod count

| Namespace | Pods | Component |
|---|---|---|
| `linkerd` | 3 | Control plane: destination, identity, proxy-injector |
| `linkerd-viz` | 5 | Dashboard, tap, metrics-api, prometheus |
| `bookinfo-linkerd` | 6 | Bookinfo app — Linkerd sidecar injected (2/2 each) |
| `istio-system` | 13 | istiod + 9×cni-node + 3×ztunnel |
| `bookinfo-istio` | 7 | Bookinfo app + waypoint — sidecarless ambient (1/1 each) |
| `bookinfo-cilium` | 6 | Bookinfo app — eBPF policy enforced (1/1 each) |
| `kube-system` | 41 | EKS addons + Cilium DaemonSets + Hubble |
