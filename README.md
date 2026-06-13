# Petclinic Platform — Service Mesh Comparison on AWS

Infrastructure for deploying [Spring Petclinic Microservices](https://github.com/spring-petclinic/spring-petclinic-microservices) across three independent EKS clusters — one per service mesh — to compare **Linkerd**, **Istio Ambient**, and **Cilium** under identical conditions.

## Architecture

```
                        ┌─────────────────────────────┐
                        │   Shared VPC (10.0.0.0/16)  │
                        │   eu-central-1a / 1b         │
                        │   RDS MySQL (shared)          │
                        └──────────────┬──────────────┘
                                       │ terraform_remote_state
              ┌────────────────────────┼────────────────────────┐
              │                        │                        │
   ┌──────────▼──────────┐  ┌─────────▼──────────┐  ┌─────────▼──────────┐
   │  petclinic-linkerd  │  │  petclinic-istio   │  │  petclinic-cilium  │
   │  EKS 1.31 / ARM64  │  │  EKS 1.31 / ARM64  │  │  EKS 1.31 / ARM64  │
   │  Linkerd sidecar    │  │  Istio Ambient      │  │  Cilium eBPF        │
   │  2× t4g.small       │  │  2× t4g.small       │  │  2× t4g.small       │
   └─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

All three clusters run the same 8-service Spring Petclinic application against a shared RDS MySQL instance, enabling apples-to-apples service mesh comparison: latency overhead, mTLS rate, control plane cost, and resource utilisation.

## Repository Structure

```
petclinic-platform/
│
├── terraform/
│   ├── environments/
│   │   ├── shared/          # Shared VPC, subnets, security groups (deployed first)
│   │   ├── linkerd/         # EKS cluster for Linkerd
│   │   ├── istio/           # EKS cluster for Istio Ambient
│   │   └── cilium/          # EKS cluster for Cilium
│   └── modules/
│       ├── vpc/             # VPC, subnets, IGW, RDS SG, ALB SG (all-public, no NAT)
│       ├── eks/             # EKS cluster, node group, OIDC, IAM, add-ons
│       ├── ecr/             # ECR repos (shared across clusters, 8 repos)
│       ├── rds/             # RDS MySQL, subnet group, parameter group, Secrets Manager
│       ├── dns/             # Route 53 zone, ACM wildcard certificate
│       ├── secrets/         # Secrets Manager (OpenAI API key)
│       ├── observability/   # IRSA roles for Prometheus, Grafana, EBS CSI
│       └── karpenter/       # SQS queue, EventBridge rules, IRSA, instance profile
│
├── helm/
│   └── petclinic-service/   # Single generic Helm chart shared by all 8 services
│
├── helm-values/
│   ├── config-server.yaml   # Per-service config (ports, env vars, init containers)
│   ├── discovery-server.yaml
│   ├── api-gateway.yaml
│   ├── customers-service.yaml
│   ├── visits-service.yaml
│   ├── vets-service.yaml
│   ├── genai-service.yaml
│   ├── admin-server.yaml
│   ├── linkerd.yaml         # Linkerd mesh annotations + replica config
│   ├── istio.yaml           # Istio injection labels + replica config
│   └── cilium.yaml          # Cilium annotations + replica config
│
├── k8s/
│   ├── base/                # Namespaces, ExternalSecret CRs
│   └── argocd/
│       ├── install/         # ArgoCD install manifests (per cluster)
│       └── applications/
│           ├── linkerd/     # 8 ArgoCD Application CRDs for Linkerd cluster
│           ├── istio/       # 8 ArgoCD Application CRDs for Istio cluster
│           └── cilium/      # 8 ArgoCD Application CRDs for Cilium cluster
│
├── .github/workflows/
│   ├── build-push.yml       # Build ARM64 images → Trivy scan → push to ECR
│   └── update-image-tags.yml # Commit new image tags → ArgoCD syncs all 3 clusters
│
├── scripts/
│   └── bootstrap-state.sh   # Create S3 bucket for Terraform state (run once)
│
└── docs/
    ├── technical-spec.md    # All infra values (CIDRs, ports, sizes, thresholds)
    ├── jira-backlog.md      # 17 epics, full story breakdown with acceptance criteria
    └── adr/                 # Architecture Decision Records
```

## Tech Stack

| Layer | Tool | Details |
|-------|------|---------|
| Cloud | AWS | eu-central-1 |
| IaC | Terraform ≥ 1.10 | AWS provider ~> 5.0, S3 native locking (no DynamoDB) |
| Clusters | Amazon EKS 1.31 | 3 clusters, ARM64 managed node groups, OIDC for IRSA |
| Nodes | t4g.small (Graviton) | 2 per cluster, ON_DEMAND (Graviton free trial until Dec 2026) |
| Registry | Amazon ECR | 8 shared repos (`petclinic/{service}`), scan-on-push, lifecycle policies |
| Database | RDS MySQL 8.0 | `db.t4g.micro`, single-AZ, shared across all 3 clusters |
| DNS | Route 53 + ACM | Wildcard cert, one A-record per cluster |
| Secrets | AWS Secrets Manager | External Secrets Operator syncs to K8s Secrets |
| Ingress | AWS Load Balancer Controller | Internet-facing ALB, target-type: ip |
| Service Meshes | Linkerd / Istio Ambient / Cilium | One per cluster for comparison |
| Observability | Prometheus + Grafana + Loki | Per-cluster stack, mesh-specific dashboards |
| Tracing | Zipkin | Distributed tracing via OpenTelemetry |
| Node Scaling | Karpenter | Per-cluster NodePool, EC2NodeClass, Spot-ready |
| CI | GitHub Actions | OIDC → AWS, build ARM64 → push ECR → commit image tag |
| CD | ArgoCD | GitOps, auto-sync on all 3 clusters (24 Applications total) |
| Packaging | Helm | Single generic chart + per-service and per-mesh values |

## Terraform State

| Environment | State Key | Purpose |
|-------------|-----------|---------|
| shared | `petclinic/shared/terraform.tfstate` | VPC, subnets, security groups |
| linkerd | `petclinic/linkerd/terraform.tfstate` | Linkerd EKS cluster + dependencies |
| istio | `petclinic/istio/terraform.tfstate` | Istio EKS cluster + dependencies |
| cilium | `petclinic/cilium/terraform.tfstate` | Cilium EKS cluster + dependencies |

State bucket: `petclinic-terraform-state-bkr` (S3 native locking, `use_lockfile = true`).

## Getting Started

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform ≥ 1.10.0
- `kubectl`, `helm`, `argocd` CLI

### 1 — Bootstrap state bucket (once)

```bash
./scripts/bootstrap-state.sh
```

### 2 — Deploy shared VPC

```bash
cd terraform/environments/shared
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

### 3 — Deploy EKS clusters (can run in parallel after step 2)

```bash
for mesh in linkerd istio cilium; do
  cd terraform/environments/$mesh
  terraform init
  terraform plan -out plan.out
  terraform apply plan.out
  cd -
done
```

### 4 — Update kubeconfig for each cluster

```bash
aws eks update-kubeconfig --name petclinic-linkerd --region eu-central-1
aws eks update-kubeconfig --name petclinic-istio   --region eu-central-1
aws eks update-kubeconfig --name petclinic-cilium  --region eu-central-1
```

### 5 — Install ArgoCD and sync applications

```bash
# Repeat for each cluster context
kubectl apply -n argocd -f k8s/argocd/install/
kubectl apply -f k8s/argocd/applications/{linkerd,istio,cilium}/
```

## Application Services

| Service | Port | MySQL | Startup Order |
|---------|------|-------|---------------|
| config-server | 8888 | No | 1st (all others wait for it) |
| discovery-server | 8761 | No | 2nd |
| api-gateway | 8080 | No | 3rd+ |
| customers-service | 8081 | Yes | 3rd+ (before visits) |
| visits-service | 8082 | Yes | After customers |
| vets-service | 8083 | Yes | 3rd+ |
| genai-service | 8084 | Optional | 3rd+ |
| admin-server | 9090 | No | 3rd+ |

## Cost Estimate

| Resource | Per Cluster | × 3 Clusters |
|----------|-------------|-------------|
| EKS control plane | $73/mo | **$219/mo** |
| EC2 t4g.small nodes (2×) | $0 | $0 (Graviton free trial) |
| RDS db.t4g.micro (shared) | $0 | $0 (RDS free tier) |
| EBS PVs (Prometheus etc.) | ~$2 | ~$6 |
| S3, ECR, Route 53, Secrets | — | ~$5 |
| **Total** | | **~$230/mo** |

> Run `terraform destroy` on unused clusters to avoid EKS control plane charges ($0.10/hr each).

## Documentation

| Doc | Purpose |
|-----|---------|
| [`docs/technical-spec.md`](docs/technical-spec.md) | All infrastructure values and module interfaces |
| [`docs/jira-backlog.md`](docs/jira-backlog.md) | Epic and story breakdown with acceptance criteria |
| [`CLAUDE.md`](CLAUDE.md) | Claude Code conventions and workflow (AI agent instructions) |

### Build Petclinic Docker images 

```


