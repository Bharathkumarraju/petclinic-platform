# Petclinic Platform — Claude Code Instructions

This repo contains ALL infrastructure code for deploying Spring Petclinic Microservices to AWS as a **service mesh comparison platform** — one shared VPC, three independent EKS clusters (Linkerd, Istio Ambient, Cilium).
The application repo (spring-petclinic-microservices) is READ-ONLY — never modify it.

## Directory Layout

```
terraform/environments/shared/       # VPC-only root module (shared by all 3 clusters)
terraform/environments/linkerd/      # EKS root module for Linkerd cluster
terraform/environments/istio/        # EKS root module for Istio Ambient cluster
terraform/environments/cilium/       # EKS root module for Cilium cluster
terraform/modules/{vpc,eks,ecr,rds,dns,secrets,observability,karpenter}/
helm/petclinic-service/              # Generic Helm chart (shared by all 8 services)
helm-values/                         # Per-service YAML + per-mesh (linkerd.yaml, istio.yaml, cilium.yaml)
k8s/base/                            # Namespaces, external-secrets CRs
k8s/argocd/install/                  # ArgoCD installation manifests
k8s/argocd/applications/{linkerd,istio,cilium}/  # ArgoCD Application CRDs (24 total)
.github/workflows/                    # CI pipelines (build + push only, ArgoCD handles CD)
scripts/                             # Operational scripts
docs/                                # Architecture docs, runbooks, ADRs
```

## Terraform Conventions

- **Provider:** AWS provider ~> 5.0, region eu-central-1, `required_version >= 1.10.0`
- **State:** S3 native locking (`use_lockfile = true`) — **no DynamoDB**. Bucket: `petclinic-terraform-state-bkr`
- **State keys:** `petclinic/shared/terraform.tfstate`, `petclinic/linkerd/terraform.tfstate`, `petclinic/istio/terraform.tfstate`, `petclinic/cilium/terraform.tfstate`
- **Remote state:** Cluster environments read VPC outputs via `data "terraform_remote_state" "shared"`
- **ECR:** Repos are shared (no env prefix): `petclinic/{service-name}` — all 3 clusters pull the same images
- **Modules:** All reusable modules in `terraform/modules/`. Environments call modules.
- **Naming:** `petclinic-{mesh}-{resource}` for cluster resources (e.g., `petclinic-linkerd-eks`, `petclinic-cilium-nodes`), `petclinic-shared-{resource}` for shared resources (e.g., `petclinic-shared-mysql`)
- **Tagging:** Every resource MUST have tags: `Project=petclinic`, `Environment={shared|linkerd|istio|cilium}`, `ManagedBy=terraform`. Cluster environments additionally tag `ServiceMesh={linkerd|istio-ambient|cilium}`.
- **Variables:** Use `variable` blocks with `description`, `type`, and `default` where sensible
- **Outputs:** Export IDs, ARNs, and endpoints needed by downstream modules
- **Sensitive values:** Never hardcode secrets. Use `sensitive = true` for secret outputs.
- **Formatting:** Run `terraform fmt` before committing. Use `terraform validate` after edits.
- **Files per module:** `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` (provider constraints)

## Kubernetes Conventions

- **Namespaces:** `petclinic-linkerd`, `petclinic-istio`, `petclinic-cilium` (one per cluster)
- **Labels:** Every resource: `app.kubernetes.io/name`, `app.kubernetes.io/part-of=petclinic`, `app.kubernetes.io/managed-by=Helm`
- **Probes:** Every Deployment MUST have readinessProbe and livenessProbe using `/actuator/health/{readiness,liveness}`
- **Resources:** Every container MUST have requests and limits (memory: 128Mi request / 512Mi limit)
- **Image tags:** Use commit SHA tags, never `latest`
- **Secrets:** Use ExternalSecret CRs pointing to AWS Secrets Manager — never store secrets in YAML
- **Service startup order:** Config Server → Discovery Server → all others (use init containers)
- **Packaging:** Helm chart (`helm/petclinic-service/`), per-service + per-mesh values in `helm-values/`
- **Deployment:** ArgoCD GitOps — CI commits image tags to Git, ArgoCD syncs to all 3 clusters

## Helm Conventions

- **Single generic chart** in `helm/petclinic-service/` shared by all 8 services across all 3 clusters
- **Per-service config** in `helm-values/{service}.yaml` (ports, env vars, init containers)
- **Per-mesh config** in `helm-values/{linkerd,istio,cilium}.yaml` (mesh annotations, sidecar injection)
- **ArgoCD merges values:** service file + mesh file when deploying
- **Template outputs** validated with `helm template` before commit

## ArgoCD Conventions

- **CI pushes images**, ArgoCD deploys. GitHub Actions NEVER runs `kubectl apply`.
- **All clusters:** auto-sync enabled (prune + self-heal) — this is a comparison platform, not production
- **Application CRDs** in `k8s/argocd/applications/{linkerd,istio,cilium}/`
- **One Application per service per cluster** (24 total: 8 services × 3 clusters)

## Security Rules (NON-NEGOTIABLE)

1. **No secrets in code** — use AWS Secrets Manager + External Secrets Operator
2. **No public S3 buckets** — block public access on all buckets
3. **No open security groups** — no 0.0.0.0/0 ingress except ALB on 80/443
4. **Encryption everywhere** — RDS encryption at rest, S3 SSE, EBS encryption
5. **Least privilege IAM** — specific actions on specific resources, never `*/*`
6. **Security groups are the perimeter** — all resources in public subnets (cost optimization), SGs enforce access control
7. **No terraform destroy without approval** — hooks block this command
8. **No *.tfvars or .env files committed** — .gitignore enforces this

## AWS Environment Details

| Setting | shared | linkerd | istio | cilium |
|---------|--------|---------|-------|--------|
| Region | eu-central-1 | eu-central-1 | eu-central-1 | eu-central-1 |
| Purpose | VPC only | Linkerd service mesh | Istio Ambient | Cilium |
| Cluster name | — | `petclinic-linkerd` | `petclinic-istio` | `petclinic-cilium` |
| K8s namespace | — | `petclinic-linkerd` | `petclinic-istio` | `petclinic-cilium` |
| State key | `petclinic/shared/…` | `petclinic/linkerd/…` | `petclinic/istio/…` | `petclinic/cilium/…` |
| EKS nodes | — | 2× t4g.small ARM | 2× t4g.small ARM | 2× t4g.small ARM |
| RDS | `petclinic-shared-mysql` (shared across all 3 clusters) | ← reads shared | ← reads shared | ← reads shared |
| Deploy mode | — | ArgoCD auto-sync | ArgoCD auto-sync | ArgoCD auto-sync |

## Application Services (8 total)

| Service | Port | Needs MySQL | Notes |
|---------|------|-------------|-------|
| config-server | 8888 | No | Must start first, Git-backed config |
| discovery-server | 8761 | No | Eureka, must start second |
| api-gateway | 8080 | No | Frontend + routing, public-facing |
| customers-service | 8081 | Yes | Owners & pets |
| visits-service | 8082 | Yes | Visit records |
| vets-service | 8083 | Yes | Vet data, Caffeine cache |
| genai-service | 8084 | Optional | Needs OPENAI_API_KEY |
| admin-server | 9090 | No | Spring Boot Admin dashboard |

## Docker Image Details

- Base: `eclipse-temurin:17`, memory limit 512M
- **Target platform:** `linux/arm64` (required for Graviton t4g nodes)
- Profile: `SPRING_PROFILES_ACTIVE=docker` (set in container)
- MySQL profile: add `mysql` to active profiles for RDS-backed services
- ECR repos: `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/{service-name}:{sha}` (shared, no env prefix)
- CI/CD builds require `docker buildx` + QEMU for ARM cross-compilation on x86 runners

## Workflow Commands

```bash
# Bootstrap (one-time, before first terraform init)
./scripts/bootstrap-state.sh

# Terraform workflow — always plan before apply, always use a saved plan
terraform fmt -recursive
terraform validate
terraform plan -out plan.out
terraform apply plan.out

# Deploy order: shared VPC first, then cluster environments
cd terraform/environments/shared  && terraform init && terraform plan -out plan.out && terraform apply plan.out
cd terraform/environments/linkerd && terraform init && terraform plan -out plan.out && terraform apply plan.out
cd terraform/environments/istio   && terraform init && terraform plan -out plan.out && terraform apply plan.out
cd terraform/environments/cilium  && terraform init && terraform plan -out plan.out && terraform apply plan.out

# Helm template validation
helm template my-release helm/petclinic-service/ -f helm-values/{service}.yaml -f helm-values/{mesh}.yaml

# ArgoCD (after install on each cluster)
kubectl port-forward svc/argocd-server -n argocd 8443:443
argocd app sync {service}-{mesh}

# Security scanning
checkov -d terraform/modules/{module}
```

## MCP Servers (configured in .mcp.json)

Five MCP servers configured at the project level:

| Server | Purpose |
|--------|---------|
| `hashicorp.terraform-mcp-server` | Terraform registry, provider/module search |
| `aws-knowledge-mcp` | AWS documentation search, regional availability |
| `awslabs.aws-pricing-mcp-server` | Cost estimation for AWS services (RDS, EKS, EC2, ALB) |
| `context7` | Up-to-date library documentation (Terraform, Kubernetes, Helm) |
| `atlassian` | Jira ticket lookup, creation, updates — drives the task-based workflow |

## CI/CD Pipeline Conventions

- **Architecture:** CI (GitHub Actions) + CD (ArgoCD). GitHub Actions NEVER deploys directly.
- **CI Platform:** GitHub Actions, OIDC federation to AWS (no long-lived credentials)
- **Image tags:** Commit SHA (`${GITHUB_SHA::7}`), never `latest`
- **ECR login:** `aws ecr get-login-password --region eu-central-1`
- **Image tag update:** CI commits new tag to `helm-values/{service}.yaml` → ArgoCD picks up on all 3 clusters
- **Scanning:** Trivy scan after Docker build, fail on CRITICAL CVEs

## Safety Hooks (configured in .claude/settings.json)

| Hook | Type | What it catches |
|------|------|----------------|
| `block-destroy.sh` | Block | `terraform destroy`, `terraform apply -destroy`, `kubectl delete` ns/deploy/svc/ingress/secret |
| `block-dangerous-rm.sh` | Block | `rm -rf` on terraform/, k8s/, helm/, helm-values/, .github/, .claude/ |
| `warn-apply-without-plan.sh` | Warn | `terraform apply` without saved plan.out file |
| `suggest-validate.sh` | Info | Suggests validate/dry-run after editing .tf, K8s .yaml, Helm, or pipeline files |
| `block-secret-commit.sh` | Block | `git add .`, committing .env, .tfvars, .pem, .key files |
| `block-mcp-destroy.sh` | Block | `destroy` via MCP Terraform/Terragrunt tools |

## Technical Specification

All infrastructure values (CIDRs, ports, instance sizes, security groups, K8s resources, probe timings, alert thresholds) are in [`docs/technical-spec.md`](docs/technical-spec.md). Every Jira story references the relevant spec section. **Read the spec before implementing any story.**

## Jira Backlog

Work is tracked in `docs/jira-backlog.md` (17 epics, E-12 removed).
Dependency chain: E-0 → E-1 (Foundation) → E-2 (Shared VPC) → E-3 (EKS ×3) → E-8 (K8s) → E-16 (Helm) → E-17 (ArgoCD) → E-14 (Karpenter)
Parallel tracks: E-4 (ECR), E-5 (RDS), E-6 (DNS), E-7 (Secrets), E-11 (Observability), E-13 (Security)
