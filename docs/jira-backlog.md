# Jira Backlog — Petclinic Platform

**Project Key:** PETPLAT (suggested)
**Board:** Kanban or Scrum
**Workflow:** Backlog → To Do → In Progress → In Review → Done

---

## Architecture: Service Mesh Comparison Platform

This project provisions **one shared VPC** and **three independent EKS clusters**, one per service mesh under evaluation:

| Environment | Cluster Name | Service Mesh | State Key |
|-------------|-------------|--------------|-----------|
| `shared` | — (VPC only) | — | `petclinic/shared/terraform.tfstate` |
| `linkerd` | `petclinic-linkerd` | Linkerd | `petclinic/linkerd/terraform.tfstate` |
| `istio` | `petclinic-istio` | Istio Ambient | `petclinic/istio/terraform.tfstate` |
| `cilium` | `petclinic-cilium` | Cilium | `petclinic/cilium/terraform.tfstate` |

Each cluster environment reads the shared VPC outputs via `terraform_remote_state`.

## Epics Overview

| Epic # | Epic | Priority | Stories |
|--------|------|----------|---------|
| E-0 | Claude Code Setup | P0 | 5 |
| E-1 | Foundation & Remote State | P0 | 5 |
| E-2 | Networking (Shared VPC) | P0 | 5 |
| E-3 | EKS Clusters (linkerd, istio, cilium) | P0 | 9 |
| E-4 | Container Registry (ECR) | P0 | 5 |
| E-5 | Database (RDS MySQL) | P0 | 6 |
| E-6 | DNS & Ingress | P1 | 5 |
| E-7 | Secrets Management (Secrets Manager) | P0 | 6 |
| E-8 | Kubernetes Manifests — Base | P0 | 8 |
| E-9 | Kubernetes Manifests — Overlays | P1 | 5 |
| E-10 | CI Pipeline (CI-only, ArgoCD handles CD) | P0 | 7 |
| E-11 | Observability | P1 | 8 |
| ~~E-12~~ | ~~Bastion Host~~ | ~~P2~~ | ~~0 (removed)~~ |
| E-13 | Security & Compliance | P1 | 8 |
| E-14 | Scaling & Cost Optimization (Karpenter) | P2 | 6 |
| E-15 | Documentation & Runbooks | P1 | 11 |
| E-16 | Helm Charts | P0 | 5 |
| E-17 | GitOps with ArgoCD | P0 | 5 |
| | | **Total** | **110** |

---

## Epic Dependencies

```
E-0 (Claude Code Setup) ──→ E-1 (Foundation)
E-1 (Foundation)
 └─→ E-2 (Shared VPC)
      └─→ E-3 (EKS ×3) ──→ E-8 (K8s Base) ──→ E-16 (Helm Charts)
      │    ├── petclinic-linkerd               │
      │    ├── petclinic-istio                 └──→ E-17 (ArgoCD) ──→ E-14 (Karpenter)
      │    └── petclinic-cilium
      │                    │
      │                    └──→ E-10 (CI-only)
      │
      └─→ E-5 (RDS — shared, all 3 clusters) ──┐
                                                │
 E-4 (ECR) ──────────────────────────────────→ │──→ E-10 (CI-only)
                                                │
 E-7 (Secrets Mgr) ─────────────────────────→ │──→ E-8 (K8s Base)
                                                │
 E-6 (DNS/Ingress) ──────────────────────────→ │──→ E-8 (K8s Base)
                                                │
 E-11 (Observability) ──────────────────────────┘
 E-13 (Security) — can run in parallel after E-3
 E-15 (Docs) — ongoing, finalize after all others
 E-16 (Helm Charts) — depends on E-8
 E-17 (ArgoCD) — depends on E-3 (all 3 clusters), E-16, E-4
```

---

# EPIC E-0: Claude Code Setup

**Priority:** P0
**Description:** Configure Claude Code for the petclinic-platform repo before writing any infrastructure code. This sets up the AI agent's context, safety guardrails, workflows, and tooling so every subsequent task benefits from intelligent assistance.
**Blocked by:** None
**Blocks:** E-1 (all subsequent work uses this configuration)

---

### PETPLAT-001: Configure MCP servers for petclinic-platform

**Type:** Task
**Priority:** P0
**Epic:** E-0 Claude Code Setup
**Story Points:** 2
**Labels:** claude, mcp, foundation
**Blocked by:** None

**Description:**
Create `.mcp.json` at the project root with all MCP servers needed for the infrastructure workflow. These servers give Claude Code access to Terraform docs, AWS knowledge, pricing data, library documentation, and Jira.

**Acceptance Criteria:**
- [ ] `.mcp.json` at petclinic-platform root
- [ ] Terraform MCP server configured (`awslabs.terraform-mcp-server`)
- [ ] AWS Knowledge MCP configured (`aws-knowledge-mcp`)
- [ ] AWS Pricing MCP configured (`awslabs.aws-pricing-mcp-server`, region: eu-central-1)
- [ ] Context7 MCP configured (library documentation)
- [ ] Atlassian MCP configured (Jira ticket management)
- [ ] No secrets stored in `.mcp.json` — credentials come from user's local environment

---

### PETPLAT-002: Create Claude Code safety hooks

**Type:** Task
**Priority:** P0
**Epic:** E-0 Claude Code Setup
**Story Points:** 3
**Labels:** claude, safety, foundation
**Blocked by:** PETPLAT-001

**Description:**
Create safety hook scripts in `.claude/hooks/` and configure them in `.claude/settings.json`. Hooks prevent Claude Code from running dangerous commands (terraform destroy, rm -rf on infra dirs, committing secrets) and warn about risky operations (apply without saved plan). Also add an informational hook that suggests `terraform validate` after editing .tf files.

**Acceptance Criteria:**
- [ ] `.claude/settings.json` with PreToolUse and PostToolUse hook configuration
- [ ] `block-destroy.sh` — blocks `terraform destroy` (exit 2, hard deny)
- [ ] `block-dangerous-rm.sh` — blocks `rm -rf` on terraform/, k8s/, .github/, docs/, scripts/
- [ ] `warn-apply-without-plan.sh` — warns on `terraform apply` without plan.out (exit 1, ask user)
- [ ] `suggest-validate.sh` — suggests `terraform validate` after .tf edits (exit 0, informational)
- [ ] `block-secret-commit.sh` — blocks git add/commit of .env, .tfvars, .pem, credentials files
- [ ] All scripts use `jq` for JSON parsing, include educational comments
- [ ] 3-tier model: block (exit 2) / warn (exit 1) / inform (exit 0)

---

### PETPLAT-003: Create Claude Code rules, agents, and skills

**Type:** Task
**Priority:** P0
**Epic:** E-0 Claude Code Setup
**Story Points:** 5
**Labels:** claude, automation, foundation
**Blocked by:** PETPLAT-82

**Description:**
Create file-pattern rules (`.claude/rules/`), review subagents (`.claude/agents/`), and operational skills (`.claude/skills/`) for the infrastructure workflow.

**Rules** load automatically when editing matching files:
- `terraform.md` — conventions for `terraform/**/*.tf`
- `kubernetes.md` — conventions for `k8s/**/*.yaml`
- `pipelines.md` — conventions for `.github/workflows/**/*.yml`
- `docs.md` — conventions for `docs/**/*.md`

**Agents** are read-only reviewers (no Write/Edit):
- `terraform-reviewer.md` — security, cost, best-practice review
- `k8s-validator.md` — manifest validation with dry-run
- `security-auditor.md` — comprehensive cross-IaC security audit
- `cost-reviewer.md` — AWS cost estimation and optimization
- `doc-reviewer.md` — documentation quality and accuracy review
- `pipeline-reviewer.md` — CI/CD pipeline security and best practices

**Skills** are slash commands for common operations:
- `/terraform-plan [env]` — init + plan (manual only)
- `/terraform-apply [env]` — apply saved plan with confirmation (manual only)
- `/security-scan [module|all]` — Checkov scan (manual only)
- `/deploy-dev [service|all]` — deploy to dev namespace (manual only)
- `/deploy-prod [service|all]` — deploy to prod with extra safety (manual only)
- `/smoke-test [env]` — health check all services (manual only)
- `/logs [service] [env]` — fetch and filter pod logs (manual only)
- `/rollback [service] [env]` — rollback deployment (manual only)
- `/review-terraform [path]` — review against checklist (auto-invocable)

**Acceptance Criteria:**
- [ ] 4 rule files with `paths:` frontmatter for selective loading (terraform, kubernetes, pipelines, docs)
- [ ] 6 agent files — read-only tools only, structured output format
- [ ] 9 skill directories with SKILL.md — 8 manual (`disable-model-invocation: true`), 1 auto-invocable
- [ ] All skills accept arguments (environment or service name)
- [ ] Deploy-prod has extra confirmation step vs deploy-dev
- [ ] Agents report findings in structured format with file:line references

---

### PETPLAT-004: Verify Claude Code configuration end-to-end

**Type:** Task
**Priority:** P0
**Epic:** E-0 Claude Code Setup
**Story Points:** 1
**Labels:** claude, verification
**Blocked by:** PETPLAT-003

**Description:**
Start a new Claude Code session in petclinic-platform/ and verify the full configuration is working: CLAUDE.md loads, MCP servers connect, skills appear, hooks fire, rules activate on file patterns.

**Acceptance Criteria:**
- [ ] CLAUDE.md project conventions visible in Claude's context
- [ ] Type `/` and all 7 skills appear in autocomplete
- [ ] Ask Claude to run `terraform destroy` — blocked by hook
- [ ] Create a test .tf file — terraform rules activate
- [ ] MCP servers respond (test with a Terraform docs search)
- [ ] All files committed to git

---

---

# EPIC E-1: Foundation & Remote State

**Priority:** P0
**Description:** Set up Terraform project structure, remote state backend (S3 + DynamoDB), provider configuration, and environment layout. This is the foundation everything else builds on.
**Blocked by:** None
**Blocks:** E-2, E-3, E-4, E-5, E-6, E-7

---

### PETPLAT-1: Create Terraform project directory structure

**Type:** Task
**Priority:** P0
**Epic:** E-1 Foundation & Remote State
**Story Points:** 2
**Labels:** terraform, foundation

**Description:**
Create the Terraform directory structure in petclinic-platform with separate environment root modules and shared reusable modules.

**Technical Spec:** [General Project Parameters](./technical-spec.md#general-project-parameters), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] `terraform/environments/shared/` — VPC-only root module (main.tf, variables.tf, outputs.tf, versions.tf)
- [ ] `terraform/environments/linkerd/` — EKS root module for Linkerd cluster (same files)
- [ ] `terraform/environments/istio/` — EKS root module for Istio Ambient cluster (same files)
- [ ] `terraform/environments/cilium/` — EKS root module for Cilium cluster (same files)
- [ ] `terraform/modules/vpc/` with main.tf, variables.tf, outputs.tf, versions.tf
- [ ] `terraform/modules/eks/` with main.tf, variables.tf, outputs.tf, versions.tf
- [ ] .gitignore includes .terraform/, *.tfstate, *.tfstate.backup, *.tfvars (sensitive), plan.out, .env, *.pem, *.key, IDE files, OS files
- [ ] .terraform.lock.hcl is NOT in .gitignore (must be committed for reproducible builds)

---

### PETPLAT-2: Create S3 bucket and DynamoDB table for Terraform state

**Type:** Task
**Priority:** P0
**Epic:** E-1 Foundation & Remote State
**Story Points:** 3
**Labels:** terraform, foundation, aws

**Description:**
Create a bootstrap script that provisions the S3 bucket (versioning enabled, encryption enabled) and DynamoDB table (LockID partition key) used for Terraform remote state. This is a one-time setup done outside Terraform itself.

**Technical Spec:** [Terraform State Backend](./technical-spec.md#terraform-state-backend)

**Acceptance Criteria:**
- [ ] `scripts/bootstrap-state.sh` script created
- [ ] S3 bucket created with versioning enabled
- [ ] S3 bucket has server-side encryption (AES256 or KMS)
- [ ] S3 bucket has public access blocked (all 4 settings)
- [ ] DynamoDB table created with `LockID` as partition key (String)
- [ ] Script is idempotent (safe to run multiple times)
- [ ] Script accepts region as parameter (default: eu-central-1)

---

### PETPLAT-3: Configure Terraform backend for shared environment

**Type:** Task
**Priority:** P0
**Epic:** E-1 Foundation & Remote State
**Story Points:** 2
**Labels:** terraform, foundation
**Blocked by:** PETPLAT-2

**Description:**
Configure the S3 backend in `terraform/environments/shared/versions.tf` (or `backend.tf`) pointing to the state bucket with key `petclinic/shared/terraform.tfstate`. This state is read by the three cluster environments via `terraform_remote_state`.

**Technical Spec:** [Terraform State Backend](./technical-spec.md#terraform-state-backend)

**Acceptance Criteria:**
- [ ] Backend configured with S3 backend, state key: `petclinic/shared/terraform.tfstate`
- [ ] DynamoDB table referenced for locking
- [ ] Encryption enabled, region eu-central-1
- [ ] `terraform init` succeeds in `terraform/environments/shared/`
- [ ] Outputs (vpc_id, public_subnet_ids) are non-sensitive so remote state consumers can read them

---

### PETPLAT-4: Configure Terraform backends for linkerd, istio, and cilium environments

**Type:** Task
**Priority:** P0
**Epic:** E-1 Foundation & Remote State
**Story Points:** 2
**Labels:** terraform, foundation
**Blocked by:** PETPLAT-2

**Description:**
Configure S3 backends in each cluster environment. Each reads shared VPC state via `data "terraform_remote_state" "shared"` pointing to `petclinic/shared/terraform.tfstate`.

**Technical Spec:** [Terraform State Backend](./technical-spec.md#terraform-state-backend)

**Acceptance Criteria:**
- [ ] `terraform/environments/linkerd/` — state key: `petclinic/linkerd/terraform.tfstate`
- [ ] `terraform/environments/istio/` — state key: `petclinic/istio/terraform.tfstate`
- [ ] `terraform/environments/cilium/` — state key: `petclinic/cilium/terraform.tfstate`
- [ ] Each has `data "terraform_remote_state" "shared"` block pointing to `petclinic/shared/terraform.tfstate`
- [ ] `terraform init` succeeds in all three environments
- [ ] `var.state_bucket` used (default: `petclinic-terraform-state`) so bucket name is not hardcoded

---

### PETPLAT-5: Configure AWS provider and Terraform versions

**Type:** Task
**Priority:** P0
**Epic:** E-1 Foundation & Remote State
**Story Points:** 2
**Labels:** terraform, foundation

**Description:**
Set up provider configuration and version constraints in all four environment root modules (shared, linkerd, istio, cilium). Pin Terraform >= 1.6.0 and AWS provider ~> 5.0.

**Technical Spec:** [General Project Parameters](./technical-spec.md#general-project-parameters)

**Acceptance Criteria:**
- [ ] `versions.tf` in shared/, linkerd/, istio/, cilium/ with required_version >= 1.6.0
- [ ] AWS provider source and version constraint (~> 5.0) defined in each
- [ ] AWS provider configured with `var.aws_region` (default: eu-central-1)
- [ ] `variables.tf` defines `aws_region` (default: eu-central-1) and `kubernetes_version` (default: 1.31)
- [ ] `variables.tf` in cluster envs defines `state_bucket` (default: `petclinic-terraform-state`) for remote state reference
- [ ] Common tags defined: `Project=petclinic`, `ManagedBy=terraform`, `ServiceMesh={linkerd|istio-ambient|cilium}` (cluster envs)
- [ ] `terraform validate` passes in all four environments

---

# EPIC E-2: Networking (Shared VPC)

**Priority:** P0
**Description:** Build a single shared VPC deployed via `terraform/environments/shared/`. All three EKS clusters (linkerd, istio, cilium) share this VPC and reference it via `terraform_remote_state`. All-public subnet design (no NAT Gateway) to minimize costs — security groups enforce access control. See ADR-0001.
**Blocked by:** E-1
**Blocks:** E-3, E-5, E-6

---

### PETPLAT-6: Create VPC module — VPC, subnets, IGW

**Type:** Story
**Priority:** P0
**Epic:** E-2 Networking
**Story Points:** 5
**Labels:** terraform, networking, vpc
**Blocked by:** PETPLAT-5

**Description:**
Create a reusable VPC module in `terraform/modules/vpc/` that provisions:

**Technical Spec:** [VPC Network Design](./technical-spec.md#vpc-network-design), [Terraform Modules](./technical-spec.md#terraform-modules)
- VPC with configurable CIDR block
- 2 public subnets across 2 AZs (for ALL resources: EKS nodes, RDS, ALB)
- Internet Gateway attached to VPC
- Single route table: all traffic via IGW
- No NAT Gateway, no private subnets (cost optimization for learning — see ADR-0001)
- Security groups are the primary access control mechanism

**Acceptance Criteria:**
- [ ] Module in `terraform/modules/vpc/` with main.tf, variables.tf, outputs.tf, versions.tf
- [ ] VPC created with DNS support and DNS hostnames enabled
- [ ] 2 public subnets with `map_public_ip_on_launch = true`
- [ ] Subnets spread across 2 AZs (eu-central-1a, eu-central-1b)
- [ ] Internet Gateway attached
- [ ] Route table: 0.0.0.0/0 → IGW
- [ ] No NAT Gateway (intentional — cost saving)
- [ ] Subnets tagged `kubernetes.io/role/elb = 1` (EKS cluster-specific tags added by each cluster environment via `aws_ec2_tag`)
- [ ] All resources tagged with Project, Environment, ManagedBy
- [ ] Outputs: vpc_id, public_subnet_ids (consumed by all 3 cluster environments via remote state)
- [ ] `terraform validate` passes

---

### ~~PETPLAT-7: REMOVED — VPC endpoints not needed~~

_VPC endpoints were needed to avoid NAT Gateway costs for private subnets. With all-public subnet design, nodes access ECR/S3/Secrets Manager directly via IGW. No VPC endpoints required — saves ~$22-65/mo._

---

### PETPLAT-8: Create baseline security groups

**Type:** Story
**Priority:** P0
**Epic:** E-2 Networking
**Story Points:** 3
**Labels:** terraform, networking, security
**Blocked by:** PETPLAT-6

**Description:**
Create baseline security groups within the VPC module or as a separate section:

**Technical Spec:** [Security Groups](./technical-spec.md#security-groups)
- EKS cluster security group (control plane)
- EKS node security group (worker nodes)
- RDS security group (MySQL port 3306, only from EKS nodes)
- ALB security group (HTTP/HTTPS from internet)

Security groups are the **primary access control boundary** in this all-public subnet design. They must be as restrictive as a traditional private subnet setup.

**Acceptance Criteria:**
- [ ] EKS cluster SG: allows 443 from node SG
- [ ] EKS node SG: allows all traffic from cluster SG, allows all traffic from other nodes (self-reference)
- [ ] RDS SG: allows 3306 from EKS node SG only (NOT 0.0.0.0/0)
- [ ] ALB SG: allows 80 and 443 from 0.0.0.0/0 (public-facing)
- [ ] All SGs have descriptive names and tags
- [ ] No overly permissive rules — SGs are the perimeter, treat them like firewall rules
- [ ] Outputs: all security group IDs
- [ ] `terraform validate` passes

---

### PETPLAT-9: Wire VPC module into shared environment

**Type:** Task
**Priority:** P0
**Epic:** E-2 Networking (Shared VPC)
**Story Points:** 2
**Labels:** terraform, networking
**Blocked by:** PETPLAT-6, PETPLAT-8

**Description:**
Call the VPC module from `terraform/environments/shared/main.tf`. This is the single VPC shared by all three EKS cluster environments. Cluster-specific subnet tags (`kubernetes.io/cluster/{name}`) are applied by each cluster environment via `aws_ec2_tag`, not here.

**Technical Spec:** [VPC Network Design](./technical-spec.md#vpc-network-design)

**Acceptance Criteria:**
- [ ] VPC module called in `terraform/environments/shared/main.tf` with `name = "petclinic-shared"`
- [ ] VPC CIDR: 10.0.0.0/16, AZs: eu-central-1a, eu-central-1b
- [ ] Public subnet CIDRs: 10.0.1.0/24, 10.0.2.0/24
- [ ] Outputs exported: vpc_id, public_subnet_ids (referenced via remote state by all 3 cluster envs)
- [ ] `terraform plan` shows expected resources (VPC, 2 subnets, IGW, route table)
- [ ] `terraform apply` succeeds

---

### PETPLAT-10: ~~Wire VPC module into prod environment~~ — superseded

_This story is superseded by the service-mesh comparison architecture. There is no separate prod VPC. All three EKS clusters share a single VPC provisioned in `terraform/environments/shared/`. See PETPLAT-9._

---

### PETPLAT-11: Deploy and verify shared VPC

**Type:** Task
**Priority:** P0
**Epic:** E-2 Networking (Shared VPC)
**Story Points:** 2
**Labels:** terraform, networking, deployment
**Blocked by:** PETPLAT-9

**Description:**
Run `terraform apply` in `terraform/environments/shared/` and verify the shared VPC is created correctly. This must complete before any of the three cluster environments can be applied.

**Technical Spec:** [VPC Network Design](./technical-spec.md#vpc-network-design)

**Acceptance Criteria:**
- [ ] `terraform apply` succeeds without errors in `terraform/environments/shared/`
- [ ] VPC (`petclinic-shared`) visible in AWS Console with CIDR 10.0.0.0/16
- [ ] 2 public subnets visible across eu-central-1a, eu-central-1b
- [ ] No NAT Gateway (intentional cost saving)
- [ ] Route table: 0.0.0.0/0 → IGW
- [ ] State file at `petclinic/shared/terraform.tfstate` in S3
- [ ] `terraform output` returns vpc_id and public_subnet_ids (consumed by linkerd/istio/cilium envs)

---

# EPIC E-3: EKS Clusters (linkerd, istio, cilium)

**Priority:** P0
**Description:** Create three independent EKS clusters — one per service mesh — all sharing the VPC from E-2. A single reusable EKS module (`terraform/modules/eks/`) is instantiated from three environment root modules: `terraform/environments/linkerd/`, `terraform/environments/istio/`, and `terraform/environments/cilium/`. Each cluster gets its own IAM roles, OIDC provider, node group, and CloudWatch log group. The `ServiceMesh` tag differentiates clusters for cost allocation and filtering.
**Blocked by:** E-2 (shared VPC must exist first)
**Blocks:** E-8, E-9, E-10, E-11

---

### PETPLAT-12: Create EKS module — cluster and IAM roles

**Type:** Story
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 5
**Labels:** terraform, eks, iam
**Blocked by:** PETPLAT-6

**Description:**
Create the reusable EKS module in `terraform/modules/eks/` — instantiated three times (once per cluster environment). Provisions:
- EKS cluster with configurable Kubernetes version (default 1.31)
- Cluster IAM role + AmazonEKSClusterPolicy
- Node IAM role + required policies (WorkerNode, CNI, ECR read-only)
- OIDC provider for IRSA
- Cluster + node security groups with minimal rules
- CloudWatch log group for control plane logs
- Subnet tags (`kubernetes.io/cluster/{name}=shared`) via `aws_ec2_tag` on the shared subnets
- Core add-ons: coredns, kube-proxy, vpc-cni

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] Module in `terraform/modules/eks/` with main.tf, variables.tf, outputs.tf, versions.tf
- [ ] `var.cluster_name` drives all resource names and tags
- [ ] `var.tags` merged onto all resources (used to set `ServiceMesh` tag per environment)
- [ ] OIDC provider created from cluster identity issuer (required for IRSA)
- [ ] `access_config { authentication_mode = "API_AND_CONFIG_MAP" }` set
- [ ] Cluster logging: api, audit, authenticator
- [ ] Managed node group: `ami_type = "AL2_ARM_64"`, default `instance_types = ["t4g.small"]`
- [ ] Add-on versions configurable via `var.addon_versions` (optional, default to AWS-managed)
- [ ] Outputs: cluster_name, cluster_endpoint, cluster_ca_certificate, oidc_provider_arn, oidc_provider_url, node_group_name, node_role_arn
- [ ] `terraform validate` passes

---

### PETPLAT-13: Add managed node group to EKS module

**Type:** Story
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 3
**Labels:** terraform, eks, compute
**Blocked by:** PETPLAT-12

**Description:**
The managed node group is included in the EKS module (PETPLAT-12). This story covers verifying and tuning the node group configuration for the service-mesh comparison use case — all three clusters use identical node sizing.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] `ami_type = "AL2_ARM_64"`, `capacity_type = "ON_DEMAND"` (Graviton t4g)
- [ ] Default: `instance_types = ["t4g.small"]`, desired=2, min=2, max=4, disk=20GB
- [ ] `update_config { max_unavailable = 1 }` set
- [ ] Nodes launched in the shared public subnets (via `var.subnet_ids` from remote state)
- [ ] Node group name: `{cluster_name}-nodes`
- [ ] `terraform validate` passes

---

### PETPLAT-14: Create kubectl access configuration for all three clusters

**Type:** Task
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 2
**Labels:** eks, access
**Blocked by:** PETPLAT-12

**Description:**
Each cluster uses `authentication_mode = "API_AND_CONFIG_MAP"`. Add access entry or aws-auth ConfigMap config so the deploying IAM principal can reach all three clusters. Add a helper script or per-cluster output for kubeconfig update.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] EKS access entry (or aws-auth) configured for the deploying IAM principal on each cluster
- [ ] Outputs include kubeconfig update command per cluster:
  - `aws eks update-kubeconfig --name petclinic-linkerd --region eu-central-1`
  - `aws eks update-kubeconfig --name petclinic-istio --region eu-central-1`
  - `aws eks update-kubeconfig --name petclinic-cilium --region eu-central-1`
- [ ] After apply, `kubectl get nodes` works against each cluster
- [ ] `scripts/kubeconfig-all.sh` (optional) updates kubeconfig for all three clusters in one shot

---

### PETPLAT-15: Wire EKS module into linkerd environment

**Type:** Task
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 2
**Labels:** terraform, eks, linkerd
**Blocked by:** PETPLAT-12, PETPLAT-13, PETPLAT-9

**Description:**
Call the EKS module from `terraform/environments/linkerd/main.tf`. VPC and subnet IDs come from `data.terraform_remote_state.shared`.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] EKS module called in `terraform/environments/linkerd/main.tf`
- [ ] `cluster_name = "petclinic-linkerd"`
- [ ] `tags = { ServiceMesh = "linkerd" }` passed to module
- [ ] `vpc_id` and `subnet_ids` sourced from `data.terraform_remote_state.shared.outputs`
- [ ] `kubernetes_version` from `var.kubernetes_version` (default 1.31)
- [ ] `terraform plan` shows expected resources

---

### PETPLAT-16: Deploy and verify linkerd EKS cluster

**Type:** Task
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 3
**Labels:** terraform, eks, deployment, linkerd
**Blocked by:** PETPLAT-15, PETPLAT-11

**Description:**
Run `terraform apply` in `terraform/environments/linkerd/` and verify the cluster is operational. Repeat for istio and cilium once linkerd validates the module works.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] `terraform apply` succeeds in `terraform/environments/linkerd/`
- [ ] Cluster `petclinic-linkerd` status: ACTIVE
- [ ] `kubectl get nodes` shows 2 Ready ARM nodes (t4g.small)
- [ ] OIDC provider visible in IAM console
- [ ] CoreDNS, kube-proxy, vpc-cni add-ons running in kube-system
- [ ] State at `petclinic/linkerd/terraform.tfstate` in S3

---

### PETPLAT-17: Wire and deploy istio and cilium EKS clusters

**Type:** Task
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 3
**Labels:** terraform, eks, istio, cilium
**Blocked by:** PETPLAT-16

**Description:**
Apply the same EKS module wiring to `terraform/environments/istio/` and `terraform/environments/cilium/`. The module is identical — only `cluster_name` and `ServiceMesh` tag differ.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] `terraform/environments/istio/main.tf`: `cluster_name = "petclinic-istio"`, `tags = { ServiceMesh = "istio-ambient" }`
- [ ] `terraform/environments/cilium/main.tf`: `cluster_name = "petclinic-cilium"`, `tags = { ServiceMesh = "cilium" }`
- [ ] `terraform apply` succeeds in both environments
- [ ] All three clusters visible in EKS console in eu-central-1
- [ ] State files at `petclinic/istio/` and `petclinic/cilium/` in S3
- [ ] `kubectl get nodes` returns 2 Ready nodes on each cluster

---

### PETPLAT-17b: Install service mesh on each cluster

**Type:** Story
**Priority:** P0
**Epic:** E-3 EKS Clusters (linkerd, istio, cilium)
**Story Points:** 5
**Labels:** eks, linkerd, istio, cilium, service-mesh
**Blocked by:** PETPLAT-17

**Description:**
Install the respective service mesh on each cluster post-EKS provisioning. This is the core of the comparison platform — each cluster runs the same Petclinic workload under a different mesh.

**Acceptance Criteria:**
- [ ] **linkerd**: `linkerd install --crds | kubectl apply -f -` → `linkerd install | kubectl apply -f -` → `linkerd check`
- [ ] **istio**: Istio Ambient mode installed via `istioctl install --set profile=ambient`; no sidecar injection, ztunnel DaemonSet running
- [ ] **cilium**: Cilium CNI replaced or configured with service mesh features enabled (`--helm-set kubeProxyReplacement=strict`)
- [ ] Each cluster has the mesh's control plane healthy before Petclinic workloads are deployed
- [ ] Mesh installation steps documented in `docs/runbook.md`

---

# EPIC E-4: Container Registry (ECR)

**Priority:** P0
**Description:** Create a single shared ECR registry with repositories for all 8 microservices. All three EKS clusters (linkerd, istio, cilium) pull from the same ECR repos — no per-cluster registry duplication. Lifecycle policies, scan-on-push, and MUTABLE tags (lab environment). Images stored at `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/{service}:{commit-sha}`. Cost: ~$1/month beyond 500 MB free tier.
**Blocked by:** E-1
**Blocks:** E-10, E-17

---

### PETPLAT-18: Create ECR module

**Type:** Story
**Priority:** P0
**Epic:** E-4 Container Registry (ECR)
**Story Points:** 3
**Labels:** terraform, ecr
**Blocked by:** PETPLAT-5

**Description:**
Create the ECR module in `terraform/modules/ecr/` that provisions one ECR private repository per microservice using `aws_ecr_repository`. Accept a list of service names and environment as variables. Configure lifecycle policies, scan-on-push, and tag immutability per environment.

**Technical Spec:** [ECR Container Registry](./technical-spec.md#ecr-container-registry), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] Module in `terraform/modules/ecr/`
- [ ] Uses `aws_ecr_repository` resource
- [ ] Accepts `service_names` list variable and `environment` variable
- [ ] Creates one ECR repo per service name under `petclinic-{env}/` namespace
- [ ] Scan-on-push enabled (`image_scanning_configuration`)
- [ ] Tag mutability configurable (MUTABLE for dev, IMMUTABLE for prod)
- [ ] Lifecycle policy: keep last 10 images, expire untagged after 7 days
- [ ] Outputs: map of service_name → repository_url, map of service_name → repository_arn
- [ ] `terraform validate` passes

---

### PETPLAT-19: Add lifecycle policy and tag immutability configuration

**Type:** Task
**Priority:** P1
**Epic:** E-4 Container Registry (ECR)
**Story Points:** 2
**Labels:** terraform, ecr, cost-optimization
**Blocked by:** PETPLAT-18

**Description:**
Configure ECR lifecycle policies to automatically clean up old images and manage storage costs. Set tag immutability per environment: MUTABLE for dev (allows re-pushing same tag during development), IMMUTABLE for prod (ensures deployed tags cannot be overwritten).

**Technical Spec:** [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] Lifecycle policy JSON: keep last 10 tagged images, expire untagged after 7 days
- [ ] `aws_ecr_lifecycle_policy` resource attached to each repository
- [ ] Tag immutability: `MUTABLE` for dev, `IMMUTABLE` for prod (variable-driven)
- [ ] Lifecycle policy tested: verify old images are pruned after threshold
- [ ] `terraform validate` passes

---

### PETPLAT-20: Wire ECR module into shared environment and deploy

**Type:** Task
**Priority:** P0
**Epic:** E-4 Container Registry (ECR)
**Story Points:** 2
**Labels:** terraform, ecr, deployment
**Blocked by:** PETPLAT-18

**Description:**
Call the ECR module from `terraform/environments/shared/main.tf` — one registry shared by all three clusters. All clusters pull images by commit SHA tag; no per-cluster repo duplication needed.

**Technical Spec:** [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] ECR module called with service_names: [config-server, discovery-server, api-gateway, customers-service, visits-service, vets-service, genai-service, admin-server]
- [ ] `terraform apply` succeeds in `terraform/environments/shared/`
- [ ] 8 ECR repositories visible in eu-central-1 under `petclinic/` prefix
- [ ] Repository URIs accessible and correct
- [ ] Scan-on-push enabled on all repos
- [ ] All three cluster node IAM roles have `AmazonEC2ContainerRegistryReadOnly` (granted via EKS module)

---

### PETPLAT-21: Create ECR login helper script

**Type:** Task
**Priority:** P2
**Epic:** E-4 Container Registry (ECR)
**Story Points:** 1
**Labels:** ecr, scripts
**Blocked by:** PETPLAT-20

**Description:**
Create `scripts/ecr-login.sh` that authenticates Docker to the ECR private registry in eu-central-1.

**Technical Spec:** [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] Script at `scripts/ecr-login.sh`
- [ ] Uses `aws ecr get-login-password --region eu-central-1` and pipes to `docker login {account}.dkr.ecr.eu-central-1.amazonaws.com`
- [ ] Works on macOS and Linux
- [ ] Accepts optional `--region` parameter (defaults to eu-central-1)

---

# EPIC E-5: Database (RDS MySQL)

**Priority:** P0
**Description:** Provision a single RDS MySQL instance in the `shared` environment alongside the VPC. All three service mesh clusters connect to this one instance. The three database-backed services (customers, visits, vets) share a single `petclinic` database (cross-service FK constraints confirmed). Include encryption, backup, and Secrets Manager integration.
**Blocked by:** E-2 (shared VPC)
**Blocks:** E-7, E-8

---

### PETPLAT-22: Create RDS module

**Type:** Story
**Priority:** P0
**Epic:** E-5 Database
**Story Points:** 5
**Labels:** terraform, rds, database
**Blocked by:** PETPLAT-6, PETPLAT-8

**Description:**
Create the RDS module in `terraform/modules/rds/` for a MySQL instance.

**Technical Spec:** [RDS Database](./technical-spec.md#rds-database), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] Module in `terraform/modules/rds/`
- [ ] RDS MySQL 8.0 instance (single shared `petclinic` database for all 3 domain services)
- [ ] DB subnet group using the VPC subnets
- [ ] RDS security group: allow 3306 from EKS node SG only
- [ ] Storage encryption enabled (KMS or default)
- [ ] Multi-AZ configurable (false for both envs — cost optimization; teach students when to enable)
- [ ] Instance class configurable (default: db.t4g.micro — free tier, ARM/Graviton)
- [ ] Allocated storage configurable (default: 20 GB, autoscaling enabled)
- [ ] Backup retention: 7 days (dev), 30 days (prod) — configurable
- [ ] Skip final snapshot configurable (true for dev, false for prod)
- [ ] DB parameter group with character set utf8mb4
- [ ] Master username and password sourced from variables (will come from Secrets Manager)
- [ ] Outputs: endpoint, port, db_instance_id
- [ ] `terraform validate` passes

---

### PETPLAT-23: Create database credentials in Secrets Manager

**Type:** Story
**Priority:** P0
**Epic:** E-5 Database
**Story Points:** 3
**Labels:** terraform, rds, secrets-manager
**Blocked by:** PETPLAT-22

**Description:**
Store the RDS master credentials in AWS Secrets Manager via Terraform. Generate a random password. Use Secrets Manager for encrypted storage of sensitive values.

**Technical Spec:** [RDS Database](./technical-spec.md#rds-database), [Secrets Management](./technical-spec.md#secrets-management)

**Acceptance Criteria:**
- [ ] Random password generated using `random_password` resource (16+ chars, special chars)
- [ ] Secrets created using `aws_secretsmanager_secret` and `aws_secretsmanager_secret_version` resources
- [ ] Secret name: `petclinic/shared/rds-credentials` (single JSON secret with `username` and `password` keys)
- [ ] RDS instance references the generated password
- [ ] Secret values NOT in Terraform state as plaintext (use `sensitive = true`)
- [ ] Output: secret ARNs (for External Secrets Operator later)
- [ ] `terraform validate` passes

---

### PETPLAT-24: Create database initialization strategy

**Type:** Story
**Priority:** P0
**Epic:** E-5 Database
**Story Points:** 3
**Labels:** rds, database
**Blocked by:** PETPLAT-22

**Description:**
Document and implement how the shared `petclinic` MySQL database gets its schemas initialized for the three database-backed services (customers, visits, vets — 7 tables total). The app has SQL scripts in `src/main/resources/db/mysql/`. Options: let Spring auto-initialize, or run scripts manually/via init container. Schema init order matters: customers first (creates `pets` table), then vets (independent), then visits (FK to `pets`).

**Technical Spec:** [RDS Database](./technical-spec.md#rds-database)

**Acceptance Criteria:**
- [ ] Strategy documented: which approach is used (Spring auto-init vs manual)
- [ ] One shared `petclinic` database created (all 3 services use the same DB — confirmed by cross-service FK: `visits.pet_id` → `pets.id`)
- [ ] Schema scripts identified: customers (owners, pets, types), visits (visits), vets (vets, specialties, vet_specialties)
- [ ] Connection string format documented for K8s ConfigMaps
- [ ] Tested: services can connect and tables exist

---

### PETPLAT-25: Wire RDS module into shared environment

**Type:** Task
**Priority:** P0
**Epic:** E-5 Database
**Story Points:** 2
**Labels:** terraform, rds
**Blocked by:** PETPLAT-22, PETPLAT-23, PETPLAT-9

**Description:**
RDS is provisioned once in `terraform/environments/shared/` alongside the VPC — a single MySQL instance is shared by all three EKS clusters. The three database-backed services (customers, visits, vets) all connect to the same `petclinic` database regardless of which mesh cluster they run on.

**Technical Spec:** [RDS Database](./technical-spec.md#rds-database)

**Acceptance Criteria:**
- [ ] RDS module called in `terraform/environments/shared/main.tf`
- [ ] Instance class: db.t4g.micro (free tier, ARM/Graviton)
- [ ] Multi-AZ: false (cost optimization)
- [ ] Skip final snapshot: true (lab environment)
- [ ] Backup retention: 7 days
- [ ] Subnets and RDS SG from VPC module outputs (within shared env)
- [ ] `terraform plan` shows expected resources
- [ ] RDS endpoint exported as output so cluster environments can reference it

---

### PETPLAT-26: Deploy and verify shared RDS

**Type:** Task
**Priority:** P0
**Epic:** E-5 Database
**Story Points:** 2
**Labels:** terraform, rds, deployment
**Blocked by:** PETPLAT-25, PETPLAT-11

**Description:**
Deploy RDS in the shared environment and verify connectivity from a pod on any of the three EKS clusters. All three clusters' nodes reside in the same VPC so connectivity is identical.

**Technical Spec:** [RDS Database](./technical-spec.md#rds-database)

**Acceptance Criteria:**
- [ ] `terraform apply` succeeds in `terraform/environments/shared/`
- [ ] RDS instance status: available
- [ ] Endpoint accessible from EKS node on any cluster (test via `kubectl run` debug pod)
- [ ] Can connect with credentials from Secrets Manager (`petclinic/shared/rds-credentials`)
- [ ] RDS SG restricts 3306 to EKS node SG only — not open to internet

---

### PETPLAT-27: ~~Wire RDS module into prod environment~~ — superseded

_Superseded by the service-mesh comparison architecture. There is no separate prod environment. A single shared RDS instance serves all three clusters. See PETPLAT-25._

---

# EPIC E-6: DNS & Ingress

**Priority:** P1
**Description:** Set up Route 53 for DNS, ACM for TLS certificates, and AWS ALB Ingress Controller on EKS to expose the API Gateway to the internet via HTTPS.
**Blocked by:** E-2, E-3
**Blocks:** E-8 (ingress manifests)

---

### PETPLAT-28: Create DNS module — Route 53 hosted zone

**Type:** Story
**Priority:** P1
**Epic:** E-6 DNS & Ingress
**Story Points:** 3
**Labels:** terraform, dns, route53
**Blocked by:** PETPLAT-5

**Description:**
Create the DNS module in `terraform/modules/dns/` with Route 53 hosted zone and ACM certificate.

**Technical Spec:** [DNS and Ingress](./technical-spec.md#dns-and-ingress), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] Module in `terraform/modules/dns/`
- [ ] Route 53 hosted zone created (domain name as variable)
- [ ] ACM certificate requested with DNS validation
- [ ] DNS validation records created in Route 53
- [ ] Certificate validation completed (or uses `aws_acm_certificate_validation`)
- [ ] Outputs: zone_id, zone_name_servers, certificate_arn
- [ ] `terraform validate` passes

---

### PETPLAT-29: Install AWS Load Balancer Controller on EKS

**Type:** Story
**Priority:** P1
**Epic:** E-6 DNS & Ingress
**Story Points:** 5
**Labels:** terraform, eks, ingress
**Blocked by:** PETPLAT-16

**Description:**
Install the AWS Load Balancer Controller on EKS using Helm (`aws-load-balancer-controller` chart). This controller watches for Ingress resources and provisions ALBs. Requires Helm CLI installed locally.

**Technical Spec:** [DNS and Ingress](./technical-spec.md#dns-and-ingress), [IRSA Roles](./technical-spec.md#irsa-roles)

**Acceptance Criteria:**
- [ ] IAM policy for the LB controller created
- [ ] IAM role for service account (IRSA) created using OIDC provider
- [ ] Helm chart values file or install command generated for the LB controller
- [ ] AWS Load Balancer Controller deployed to kube-system namespace via `helm install`
- [ ] Controller pods running and healthy
- [ ] IngressClass resource created for `alb`
- [ ] Verified: controller can create ALBs (test with a simple Ingress)

---

### PETPLAT-30: Create Ingress manifest for API Gateway

**Type:** Story
**Priority:** P1
**Epic:** E-6 DNS & Ingress
**Story Points:** 3
**Labels:** k8s, ingress, networking
**Blocked by:** PETPLAT-29, PETPLAT-28

**Description:**
Create the K8s Ingress resource that routes external HTTPS traffic to the API Gateway service.

**Technical Spec:** [DNS and Ingress](./technical-spec.md#dns-and-ingress)

**Acceptance Criteria:**
- [ ] Ingress manifest at `k8s/base/ingress/ingress.yaml`
- [ ] Uses `alb` IngressClass
- [ ] Annotations for internet-facing ALB, HTTPS redirect, ACM certificate ARN
- [ ] Routes: `/` → api-gateway service on port 8080
- [ ] Health check path: `/actuator/health`
- [ ] ALB created and accessible after applying

---

### PETPLAT-31: Create DNS record pointing to ALB

**Type:** Task
**Priority:** P1
**Epic:** E-6 DNS & Ingress
**Story Points:** 2
**Labels:** terraform, dns
**Blocked by:** PETPLAT-28, PETPLAT-30

**Description:**
Create a Route 53 A record (alias) pointing the domain to the ALB created by the ingress controller.

**Technical Spec:** [DNS and Ingress](./technical-spec.md#dns-and-ingress)

**Acceptance Criteria:**
- [ ] Route 53 alias record created per cluster (e.g., petclinic-linkerd.example.com, petclinic-istio.example.com, petclinic-cilium.example.com → respective ALBs)
- [ ] Record type: A with alias to ALB
- [ ] App accessible via domain name over HTTPS
- [ ] HTTP redirects to HTTPS

---

### PETPLAT-32: Wire DNS module into dev environment

**Type:** Task
**Priority:** P1
**Epic:** E-6 DNS & Ingress
**Story Points:** 1
**Labels:** terraform, dns
**Blocked by:** PETPLAT-28

**Description:**
Call the DNS module from the dev environment.

**Technical Spec:** [DNS and Ingress](./technical-spec.md#dns-and-ingress)

**Acceptance Criteria:**
- [ ] DNS module called in dev main.tf
- [ ] Domain configured
- [ ] ACM certificate created and validated
- [ ] `terraform plan` shows expected resources

---

# EPIC E-7: Secrets Management (Secrets Manager)

**Priority:** P0
**Description:** Set up AWS Secrets Manager for all application secrets and install External Secrets Operator on EKS to sync secrets into Kubernetes Secrets. Secrets Manager provides encrypted storage and centralized secret management for the application.
**Blocked by:** E-3, E-5
**Blocks:** E-8

---

### PETPLAT-33: Create Secrets Manager Terraform resources (non-RDS secrets)

**Type:** Story
**Priority:** P0
**Epic:** E-7 Secrets Management (Secrets Manager)
**Story Points:** 3
**Labels:** terraform, secrets-manager
**Blocked by:** PETPLAT-5

**Description:**
Create the secrets module in `terraform/modules/secrets/` to manage **non-RDS** application secrets in AWS Secrets Manager using `aws_secretsmanager_secret` and `aws_secretsmanager_secret_version`. Note: RDS credentials are created by PETPLAT-23 in the RDS module — do NOT duplicate them here. This module handles all other application secrets.

**Technical Spec:** [Secrets Management](./technical-spec.md#secrets-management), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] Module in `terraform/modules/secrets/`
- [ ] Secrets created using `aws_secretsmanager_secret` and `aws_secretsmanager_secret_version` resources
- [ ] Secrets created: `petclinic/{env}/openai-api-key`
- [ ] Optional: `petclinic/{env}/config-server/git-username`, `petclinic/{env}/config-server/git-password`
- [ ] RDS credentials NOT created here (owned by RDS module — PETPLAT-23)
- [ ] Secret values NOT hardcoded — accept as variables
- [ ] Outputs: secret ARNs for each
- [ ] `terraform validate` passes

---

### PETPLAT-34: Install External Secrets Operator on EKS

**Type:** Story
**Priority:** P0
**Epic:** E-7 Secrets Management (Secrets Manager)
**Story Points:** 5
**Labels:** k8s, secrets-manager, eks
**Blocked by:** PETPLAT-16, PETPLAT-37

**Description:**
Install External Secrets Operator (ESO) on the EKS cluster. ESO will sync secrets from AWS Secrets Manager into Kubernetes Secret objects using the `SecretsManager` provider.

**Technical Spec:** [Secrets Management](./technical-spec.md#secrets-management), [IRSA Roles](./technical-spec.md#irsa-roles)

**Acceptance Criteria:**
- [ ] ESO installed via kubectl apply (CRDs + controller)
- [ ] ESO pods running in `external-secrets` namespace
- [ ] IAM role for service account (IRSA) created with Secrets Manager read permissions (`secretsmanager:GetSecretValue`, `secretsmanager:DescribeSecret`)
- [ ] SecretStore or ClusterSecretStore resource created with `provider: aws` and `service: SecretsManager`
- [ ] Test: create a sample ExternalSecret referencing a Secrets Manager secret and verify K8s Secret is created
- [ ] Documented: how to add new secrets

---

### PETPLAT-35: Create ExternalSecret for RDS credentials

**Type:** Task
**Priority:** P0
**Epic:** E-7 Secrets Management (Secrets Manager)
**Story Points:** 2
**Labels:** k8s, secrets-manager
**Blocked by:** PETPLAT-34, PETPLAT-23

**Description:**
Create ExternalSecret resource that syncs RDS credentials from Secrets Manager into K8s.

**Technical Spec:** [Secrets Management](./technical-spec.md#secrets-management)

**Acceptance Criteria:**
- [ ] ExternalSecret manifest at `k8s/base/external-secrets/rds-credentials.yaml`
- [ ] References Secrets Manager secret: `petclinic/{env}/rds-credentials` (single JSON secret)
- [ ] Uses `remoteRef.key` with `remoteRef.property` to extract `username` and `password` from JSON
- [ ] Creates K8s Secret with keys: `username`, `password`
- [ ] Refresh interval: 1h
- [ ] Secret created in the correct namespace
- [ ] Verified: `kubectl get secret` shows the created secret

---

### PETPLAT-36: Create ExternalSecret for OpenAI API key

**Type:** Task
**Priority:** P0
**Epic:** E-7 Secrets Management (Secrets Manager)
**Story Points:** 1
**Labels:** k8s, secrets-manager
**Blocked by:** PETPLAT-34, PETPLAT-33

**Description:**
Create ExternalSecret for the GenAI service's OpenAI API key from Secrets Manager.

**Technical Spec:** [Secrets Management](./technical-spec.md#secrets-management)

**Acceptance Criteria:**
- [ ] ExternalSecret manifest at `k8s/base/external-secrets/openai-api-key.yaml`
- [ ] References Secrets Manager secret: `petclinic/{env}/openai-api-key`
- [ ] Creates K8s Secret with key: `OPENAI_API_KEY`
- [ ] Verified: secret created in K8s

---

### PETPLAT-37: Create IRSA role for External Secrets Operator

**Type:** Task
**Priority:** P0
**Epic:** E-7 Secrets Management (Secrets Manager)
**Story Points:** 3
**Labels:** terraform, iam, secrets-manager
**Blocked by:** PETPLAT-12

**Description:**
Create an IAM role with a trust policy for the ESO service account (IRSA) with permissions to read from Secrets Manager.

**Technical Spec:** [IRSA Roles](./technical-spec.md#irsa-roles)

**Acceptance Criteria:**
- [ ] IAM role created with OIDC trust policy for the ESO service account
- [ ] Policy: `secretsmanager:GetSecretValue`, `secretsmanager:DescribeSecret` on `arn:aws:secretsmanager:*:*:secret:petclinic/*`
- [ ] Policy: `kms:Decrypt` for encrypted secrets (if using custom KMS key)
- [ ] Role ARN output for use in ESO ServiceAccount annotation
- [ ] `terraform validate` passes

---

# EPIC E-8: Kubernetes Manifests — Base

**Priority:** P0
**Description:** Create base Kubernetes manifests for all 8 microservices. Each service gets its own directory with Deployment, Service, ConfigMap, and ServiceAccount. Respect startup order dependencies.
**Blocked by:** E-3, E-5, E-7
**Blocks:** E-9, E-10, E-11

---

### PETPLAT-38: Create K8s namespaces manifest

**Type:** Task
**Priority:** P0
**Epic:** E-8 K8s Base Manifests
**Story Points:** 1
**Labels:** k8s
**Blocked by:** PETPLAT-16

**Description:**
Create namespace definitions — one namespace per cluster (applied to the matching cluster). Each namespace is labeled for the service mesh it runs under.

**Technical Spec:** [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `k8s/base/namespaces.yaml` with petclinic-linkerd, petclinic-istio, petclinic-cilium namespaces (applied to respective cluster)
- [ ] Namespaces labeled: `app.kubernetes.io/part-of=petclinic`, `service-mesh={linkerd|istio|cilium}`
- [ ] Mesh-specific labels added where required (Linkerd injection annotation, Istio ambient label `istio.io/dataplane-mode=ambient`)
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-39: Create Config Server K8s manifests

**Type:** Story
**Priority:** P0
**Epic:** E-8 K8s Base Manifests
**Story Points:** 3
**Labels:** k8s, config-server
**Blocked by:** PETPLAT-38

**Description:**
Config Server must deploy first. All other services depend on it.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `k8s/base/config-server/deployment.yaml` — 1 replica, port 8888, SPRING_PROFILES_ACTIVE=docker
- [ ] `k8s/base/config-server/service.yaml` — ClusterIP, port 8888
- [ ] `k8s/base/config-server/configmap.yaml` — GIT_REPO URL for config
- [ ] Startup probe: /actuator/health, port 8888
- [ ] Readiness probe: /actuator/health, port 8888
- [ ] Liveness probe: /actuator/health, port 8888
- [ ] Resource requests: cpu=100m, memory=128Mi; limits: cpu=500m, memory=512Mi
- [ ] Image: `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic-{env}/config-server:<TAG>` (placeholder)
- [ ] ServiceAccount created
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-40: Create Discovery Server K8s manifests

**Type:** Story
**Priority:** P0
**Epic:** E-8 K8s Base Manifests
**Story Points:** 3
**Labels:** k8s, discovery-server
**Blocked by:** PETPLAT-39

**Description:**
Discovery Server (Eureka) depends on Config Server. Must be running before domain services start.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `k8s/base/discovery-server/deployment.yaml` — port 8761, env: CONFIG_SERVER_URL=http://config-server:8888
- [ ] `k8s/base/discovery-server/service.yaml` — ClusterIP, port 8761
- [ ] Init container or readiness dependency on Config Server
- [ ] Probes: readiness and liveness on /actuator/health endpoints
- [ ] Resources: requests cpu=100m, memory=128Mi; limits cpu=500m, memory=512Mi
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-41: Create domain services K8s manifests (customers, visits, vets)

**Type:** Story
**Priority:** P0
**Epic:** E-8 K8s Base Manifests
**Story Points:** 5
**Labels:** k8s, domain-services, rds
**Blocked by:** PETPLAT-40, PETPLAT-35

**Description:**
Create manifests for the three database-backed services. They need MySQL connection config and credentials from Secrets Manager (synced to K8s Secrets via ESO).

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests), [RDS Database](./technical-spec.md#rds-database)

**Acceptance Criteria:**
- [ ] Manifests for customers-service (port 8081), visits-service (port 8082), vets-service (port 8083)
- [ ] Each: Deployment, Service (ClusterIP), ConfigMap, ServiceAccount
- [ ] Spring profile: `docker,mysql` (activates MySQL instead of HSQLDB)
- [ ] ConfigMap: SPRING_DATASOURCE_URL pointing to RDS endpoint
- [ ] Secret reference: SPRING_DATASOURCE_USERNAME and SPRING_DATASOURCE_PASSWORD from K8s secret (synced by ESO)
- [ ] CONFIG_SERVER_URL env var pointing to config-server service
- [ ] Readiness/liveness probes on /actuator/health endpoints
- [ ] Resources: cpu=100m/500m, memory=128Mi/512Mi
- [ ] `kubectl apply --dry-run=client` passes for all three

---

### PETPLAT-42: Create GenAI Service K8s manifests

**Type:** Story
**Priority:** P0
**Epic:** E-8 K8s Base Manifests
**Story Points:** 2
**Labels:** k8s, genai
**Blocked by:** PETPLAT-40, PETPLAT-36

**Description:**
GenAI service needs the OpenAI API key from Secrets Manager (synced to K8s Secret via ESO).

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `k8s/base/genai-service/` — Deployment (port 8084), Service, ServiceAccount
- [ ] OPENAI_API_KEY from K8s secret (synced by ESO)
- [ ] CONFIG_SERVER_URL env var
- [ ] Probes on /actuator/health endpoints
- [ ] Resources: cpu=100m/500m, memory=128Mi/512Mi
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-43: Create API Gateway K8s manifests

**Type:** Story
**Priority:** P0
**Epic:** E-8 K8s Base Manifests
**Story Points:** 3
**Labels:** k8s, api-gateway
**Blocked by:** PETPLAT-40

**Description:**
API Gateway routes traffic to all domain services and serves the frontend. This is the entry point from the ALB ingress.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `k8s/base/api-gateway/` — Deployment (port 8080), Service (ClusterIP), ServiceAccount
- [ ] CONFIG_SERVER_URL and DISCOVERY_SERVER_URL env vars
- [ ] Probes: readiness and liveness
- [ ] Resources: cpu=200m/1000m, memory=128Mi/512Mi (gateway handles more traffic)
- [ ] Service is the target for the Ingress resource
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-44: Create Admin Server K8s manifests

**Type:** Story
**Priority:** P1
**Epic:** E-8 K8s Base Manifests
**Story Points:** 2
**Labels:** k8s, admin-server
**Blocked by:** PETPLAT-40

**Description:**
Spring Boot Admin for monitoring all services.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `k8s/base/admin-server/` — Deployment (port 9090), Service, ServiceAccount
- [ ] CONFIG_SERVER_URL env var
- [ ] Probes on /actuator/health endpoints
- [ ] Resources: cpu=100m/500m, memory=128Mi/512Mi
- [ ] `kubectl apply --dry-run=client` passes

---

# EPIC E-9: Kubernetes Manifests — Overlays

**Priority:** P1
**Description:** Create per-mesh overlay values that patch replica counts, resource limits, HPA, and image tags for each service mesh cluster. With Helm (E-16), cluster differences are expressed as Helm values files (`helm-values/linkerd.yaml`, `helm-values/istio.yaml`, `helm-values/cilium.yaml`). These overlay definitions inform the Helm values structure.
**Blocked by:** E-8
**Blocks:** E-14, E-16

---

### PETPLAT-45: Create per-mesh overlay values (linkerd, istio, cilium)

**Type:** Story
**Priority:** P0
**Epic:** E-9 K8s Overlays
**Story Points:** 3
**Labels:** k8s, overlays
**Blocked by:** PETPLAT-38 through PETPLAT-44

**Description:**
Define per-cluster Helm values for each service mesh cluster. All three run the same workload with the same replica counts — differences are the namespace, mesh-specific annotations, and any sidecar/ambient labels. These requirements feed into `helm-values/{linkerd,istio,cilium}.yaml` in E-16.

**Technical Spec:** [Kubernetes Overlays](./technical-spec.md#kubernetes-overlays), [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] All services: 1 replica per cluster (lab sizing — t4g.small nodes)
- [ ] Namespaces: `petclinic-linkerd` / `petclinic-istio` / `petclinic-cilium` per cluster
- [ ] Image tags: SHA-based (same image pulled by all three clusters)
- [ ] Linkerd values: `podAnnotations: linkerd.io/inject: enabled`
- [ ] Istio values: namespace label `istio.io/dataplane-mode: ambient` (no per-pod annotations needed)
- [ ] Cilium values: no mesh annotations needed (CNI-level)
- [ ] Settings documented for translation into `helm-values/{linkerd,istio,cilium}.yaml` (E-16)

---

### PETPLAT-46: ~~Create prod overlay patches~~ — superseded

_Superseded by the service-mesh comparison architecture. There is no prod environment. Per-mesh overlay values are defined in PETPLAT-45._

---

### PETPLAT-47: Add Horizontal Pod Autoscaler (all clusters)

**Type:** Story
**Priority:** P1
**Epic:** E-9 K8s Overlays
**Story Points:** 3
**Labels:** k8s, scaling
**Blocked by:** PETPLAT-45, PETPLAT-72

**Description:**
Add HPA resources in prod overlay for stateless services.

**Technical Spec:** [Kubernetes Overlays](./technical-spec.md#kubernetes-overlays)

**Acceptance Criteria:**
- [ ] HPA for api-gateway: min=2, max=6, target CPU=70%
- [ ] HPA for customers, visits, vets: min=2, max=4, target CPU=70%
- [ ] HPA for genai-service: min=1, max=3, target CPU=70%
- [ ] Metrics server installed on EKS (required for HPA)
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-48: Deploy all services to dev namespace and verify

**Type:** Story
**Priority:** P0
**Epic:** E-9 K8s Overlays
**Story Points:** 5
**Labels:** k8s, deployment, verification
**Blocked by:** PETPLAT-45, PETPLAT-16, PETPLAT-24, PETPLAT-26, PETPLAT-35, PETPLAT-36, PETPLAT-85

**Description:**
Deploy all 8 services to dev namespace and verify the full application is working. Images must already exist in ECR (PETPLAT-85). Initial deployment can use `helm install` directly or ArgoCD sync (E-17). Subsequent deployments are handled by ArgoCD.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Overlays](./technical-spec.md#kubernetes-overlays), [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] All 8 deployments running in petclinic-linkerd namespace (validate linkerd cluster first; repeat for istio and cilium)
- [ ] All pods in Ready state
- [ ] Config Server healthy: `curl config-server:8888/actuator/health`
- [ ] Discovery Server shows all services registered: `curl discovery-server:8761/eureka/apps`
- [ ] API Gateway accessible and routing to domain services
- [ ] Customers, Visits, Vets services can read/write to RDS
- [ ] GenAI service responds (with valid API key)
- [ ] Admin Server shows all services

---

# EPIC E-10: CI Pipeline (CI-only, ArgoCD handles CD)

**Priority:** P0
**Description:** Create GitHub Actions workflows for building Docker images, pushing to ECR, and updating image tags in the Git repo. ArgoCD (E-17) handles the CD side by detecting tag changes and deploying to EKS. Uses OIDC federation for AWS auth. No `kubectl apply` in CI -- GitOps pattern only.
**Blocked by:** E-3, E-4, E-8
**Blocks:** None

---

### PETPLAT-49: Create build and push pipeline

**Type:** Story
**Priority:** P0
**Epic:** E-10 CI Pipeline
**Story Points:** 5
**Labels:** cicd, github-actions, ecr
**Blocked by:** PETPLAT-52, PETPLAT-16

**Description:**
Create the GitHub Actions workflow that builds Docker images for changed services and pushes to ECR. Lives in the application repo fork — the workflow triggers on push to main in the app repo context. Uses OIDC federation (PETPLAT-52) for AWS authentication. Only builds images for services whose directories changed — not all 8 on every push.

**Technical Spec:** [CI/CD Pipeline](./technical-spec.md#cicd-pipeline), [Docker Build](./technical-spec.md#docker-build), [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] `.github/workflows/build-push.yml` in the application repo fork (not the platform repo)
- [ ] Trigger: `on: push: branches: [main]`
- [ ] `dorny/paths-filter` detects which of the 8 service directories changed — one boolean per service
- [ ] Matrix strategy — only services where the paths-filter output is `true` are included in the build matrix
- [ ] Set up Docker Buildx + QEMU for ARM64 cross-compilation on x86 runners
- [ ] Authenticate to AWS via OIDC — `aws-actions/configure-aws-credentials` with `role-to-assume` (no hardcoded access keys)
- [ ] Login to ECR using `aws-actions/amazon-ecr-login`
- [ ] Build image for each changed service — `--platform linux/arm64`
- [ ] Trivy scan each image before push — fail on CRITICAL vulnerabilities
- [ ] Tag with 7-character commit SHA — `github.sha[:7]`
- [ ] Push to ECR: `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/{service}:{sha}`
- [ ] After all changed services are pushed, fire `repository_dispatch` event type `app-image-built` to the platform repo using `PLATFORM_REPO_TOKEN` secret — payload includes SHA and list of changed services only
- [ ] Pipeline succeeds end-to-end

---

### PETPLAT-50: Create update-image-tags workflow

**Type:** Story
**Priority:** P0
**Epic:** E-10 CI Pipeline
**Story Points:** 5
**Labels:** cicd, github-actions, gitops
**Blocked by:** PETPLAT-49

**Description:**
Create GitHub Actions workflow in the platform repo that updates image tags in Helm values files when the build workflow signals completion. Triggered by a `repository_dispatch` event from the app repo — not by a direct workflow dependency. Updates only the services included in the dispatch payload, then commits and pushes so ArgoCD detects the change and deploys.

**Technical Spec:** [CI/CD Pipeline](./technical-spec.md#cicd-pipeline), [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd)

**Acceptance Criteria:**
- [ ] `.github/workflows/update-image-tags.yml` in the platform repo
- [ ] Trigger: `on: repository_dispatch: types: [app-image-built]`
- [ ] Receives payload from app repo: SHA and list of changed services
- [ ] Uses `yq` to update `image.tag` in `helm-values/{service}.yaml` — only for services in the payload
- [ ] Commits and pushes updated values files to the platform repo
- [ ] Git commit message format: `ci: update image tags to {sha} ({service-list})`
- [ ] ArgoCD detects the commit and triggers deployment (verified via ArgoCD UI)
- [ ] No `kubectl apply` or `aws eks update-kubeconfig` in this workflow

---

### ~~PETPLAT-51: REMOVED — deploy-to-prod pipeline replaced by ArgoCD~~

_Prod deployment is now handled by ArgoCD (E-17) with manual sync policy. No separate deploy-prod workflow needed. ArgoCD Application CRD for prod is configured with `syncPolicy: manual` requiring explicit approval in ArgoCD UI. See PETPLAT-109._

---

### PETPLAT-52: Configure OIDC federation and GitHub Secrets

**Type:** Task
**Priority:** P0
**Epic:** E-10 CI Pipeline
**Story Points:** 3
**Labels:** cicd, github-actions
**Blocked by:** E-1

**Description:**
Configure OIDC federation between GitHub Actions and AWS, plus GitHub Secrets for CI. Prod deployment approval is handled by ArgoCD manual sync (not GitHub Environments).

**Technical Spec:** [CI/CD Pipeline](./technical-spec.md#cicd-pipeline)

**Acceptance Criteria:**
- [ ] OIDC IAM role for GitHub Actions (federated identity — no long-lived keys)
- [ ] GitHub Secrets: AWS region, AWS account ID (for ECR registry URL)
- [ ] IAM role permissions include `ecr:GetAuthorizationToken`, `ecr:BatchCheckLayerAvailability`, `ecr:PutImage`, etc.
- [ ] Documentation: how to configure OIDC federation

---

### PETPLAT-53: Create reusable pipeline templates

**Type:** Task
**Priority:** P2
**Epic:** E-10 CI Pipeline
**Story Points:** 3
**Labels:** cicd, github-actions
**Blocked by:** PETPLAT-49, PETPLAT-50

**Description:**
Extract common workflow steps into reusable workflows or composite actions. Since CD is handled by ArgoCD, reusable templates focus on CI steps (build, push, tag update).

**Technical Spec:** [CI/CD Pipeline](./technical-spec.md#cicd-pipeline)

**Acceptance Criteria:**
- [ ] `.github/workflows/reusable/ecr-login.yml` — reusable ECR login workflow
- [ ] `.github/workflows/reusable/update-tags.yml` — reusable image tag update workflow
- [ ] Main workflows call reusable workflows
- [ ] DRY: no duplicated steps between build-push and update-tags workflows

---

### PETPLAT-54: Implement rollback strategy

**Type:** Story
**Priority:** P1
**Epic:** E-10 CI Pipeline
**Story Points:** 3
**Labels:** cicd, operations, gitops
**Blocked by:** PETPLAT-50

**Description:**
Document and implement rollback procedures for failed deployments. With ArgoCD handling CD, rollback is done by reverting the image tag in Git (GitOps rollback) or using ArgoCD's rollback feature.

**Technical Spec:** [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd), [CI/CD Pipeline](./technical-spec.md#cicd-pipeline)

**Acceptance Criteria:**
- [ ] GitOps rollback: revert image tag commit in Git → ArgoCD syncs previous version
- [ ] ArgoCD rollback: use ArgoCD UI or CLI to rollback to previous sync
- [ ] `kubectl rollout undo` documented as emergency fallback
- [ ] Rollback tested: deploy bad image → git revert → ArgoCD syncs → service recovered
- [ ] Documented in runbook

---

# EPIC E-11: Observability

**Priority:** P1
**Description:** Deploy the observability stack: Prometheus for metrics, Grafana for dashboards and log exploration, Loki for log aggregation, Alertmanager for alert routing and notifications (both metric and log alerts), FluentBit for log collection (forwards to Loki), and Zipkin for distributed tracing. All tools run in-cluster — no AWS-side logging infrastructure required.
**Blocked by:** E-3
**Blocks:** None

---

### PETPLAT-55: Deploy Prometheus on EKS

**Type:** Story
**Priority:** P1
**Epic:** E-11 Observability
**Story Points:** 5
**Labels:** k8s, observability, prometheus
**Blocked by:** PETPLAT-16, PETPLAT-84

**Description:**
Deploy Prometheus on EKS to scrape metrics from all 8 Petclinic services via their /actuator/prometheus endpoints.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Prometheus deployed to monitoring namespace
- [ ] Scrape config targets all 8 services on /actuator/prometheus
- [ ] Scrape interval: 15s
- [ ] Prometheus web UI accessible (port-forward or ingress)
- [ ] Verified: metrics from all services visible in Prometheus
- [ ] Persistent volume for metric retention (configurable days)

---

### PETPLAT-56: Deploy Grafana on EKS

**Type:** Story
**Priority:** P1
**Epic:** E-11 Observability
**Story Points:** 3
**Labels:** k8s, observability, grafana
**Blocked by:** PETPLAT-55

**Description:**
Deploy Grafana with Prometheus and Loki as datasources.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Grafana deployed to monitoring namespace
- [ ] Prometheus datasource auto-configured
- [ ] Loki datasource auto-configured
- [ ] Grafana accessible (port-forward or ingress)
- [ ] Admin credentials stored in K8s Secret (or Secrets Manager via ESO)
- [ ] Persistent volume for dashboard state

---

### PETPLAT-57: Create per-service Grafana dashboards

**Type:** Story
**Priority:** P1
**Epic:** E-11 Observability
**Story Points:** 5
**Labels:** observability, grafana, dashboards
**Blocked by:** PETPLAT-56

**Description:**
Create Grafana dashboards for each Petclinic service showing key metrics.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Dashboard per service showing: request rate (RPS), error rate, p95/p99 latency
- [ ] Overview dashboard showing all services at a glance
- [ ] JVM metrics dashboard: heap usage, GC pauses, thread count
- [ ] Dashboards exported as JSON in `k8s/base/observability/grafana-dashboards/`
- [ ] Dashboards provisioned automatically via ConfigMap

---

### PETPLAT-58: Create alerting rules

**Type:** Story
**Priority:** P1
**Epic:** E-11 Observability
**Story Points:** 3
**Labels:** observability, prometheus, alerts
**Blocked by:** PETPLAT-55

**Description:**
Create Prometheus alerting rules for key conditions.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Alert: Service down (target up == 0) per service
- [ ] Alert: High error rate (> 5% 5xx responses over 5 min)
- [ ] Alert: High latency (p95 > 500ms over 5 min)
- [ ] Alert: Pod restart loop (> 3 restarts in 15 min)
- [ ] Alert: High memory usage (> 80% of limit)
- [ ] Alert rules stored as ConfigMap or PrometheusRule CR

---

### PETPLAT-59: Deploy Loki and FluentBit for centralized logging

**Type:** Story
**Priority:** P1
**Epic:** E-11 Observability
**Story Points:** 5
**Labels:** k8s, observability, logging
**Blocked by:** PETPLAT-16

**Description:**
Deploy Loki for log aggregation and FluentBit as a DaemonSet to collect and forward container logs to Loki. All in-cluster — no AWS IAM roles or CloudWatch resources required.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Loki deployed to monitoring namespace with PersistentVolume (10Gi dev, 50Gi prod)
- [ ] Loki log retention configured (7 days dev, 30 days prod)
- [ ] FluentBit DaemonSet deployed on all nodes
- [ ] FluentBit output configured to `http://loki.monitoring:3100`
- [ ] Logs from all 8 services visible in Grafana (Explore → Loki datasource)
- [ ] Loki alert rules defined for error spike and OOM patterns
- [ ] No IRSA role required — Loki is in-cluster

---

### PETPLAT-60: Deploy Zipkin for distributed tracing

**Type:** Story
**Priority:** P2
**Epic:** E-11 Observability
**Story Points:** 3
**Labels:** k8s, observability, tracing
**Blocked by:** PETPLAT-16

**Description:**
Deploy Zipkin on EKS for distributed tracing. The app already exports traces via OpenTelemetry.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Zipkin deployed to tracing namespace
- [ ] Port 9411 accessible (port-forward or ingress)
- [ ] Services configured to send traces to Zipkin endpoint (via ConfigMap env var)
- [ ] Traces visible in Zipkin UI showing cross-service calls
- [ ] Verified: trace from API Gateway → domain service visible

---

### ~~PETPLAT-61: Create Terraform observability module for CloudWatch resources — REMOVED~~

_Removed: observability stack is fully in-cluster (Prometheus, Loki, Grafana, FluentBit, Zipkin, Alertmanager). No AWS-side resources required — no CloudWatch log groups, no FluentBit IRSA role, no CloudWatch Alarms. PETPLAT-59 covers Loki + FluentBit deployment._

---

# ~~EPIC E-12: Bastion Host — REMOVED~~

_Bastion host removed from project scope. Not needed for this learning environment:_
- _kubectl access: run locally with `aws eks update-kubeconfig`_
- _RDS debugging: use a debug pod (`kubectl run -it debug --image=mysql:8 -- mysql -h <endpoint>`)_
- _Emergency access: AWS Systems Manager Session Manager (free, no SSH keys)_

_PETPLAT-62, 63, 64, 65 all removed. Saves ~$15/mo per student + eliminates SSH key management._

---

# EPIC E-13: Security & Compliance

**Priority:** P1
**Description:** Security hardening across the stack: IAM least privilege, K8s RBAC and network policies, image scanning, Terraform security scanning, security group audit.
**Blocked by:** E-3
**Blocks:** None

---

### PETPLAT-66: Run Checkov scan on all Terraform code

**Type:** Story
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 3
**Labels:** security, terraform, checkov
**Blocked by:** PETPLAT-11, PETPLAT-16, PETPLAT-26

**Description:**
Run Checkov on all Terraform modules and fix critical/high findings.

**Technical Spec:** [Security Controls](./technical-spec.md#security-controls)

**Acceptance Criteria:**
- [ ] Checkov scan run on `terraform/modules/` and `terraform/environments/`
- [ ] All CRITICAL findings fixed
- [ ] All HIGH findings fixed or documented with justification
- [ ] MEDIUM findings reviewed and prioritized
- [ ] Scan results documented
- [ ] No secrets in Terraform code

---

### PETPLAT-67: Implement K8s network policies

**Type:** Story
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 5
**Labels:** k8s, security, networking
**Blocked by:** PETPLAT-38, PETPLAT-43

**Description:**
Create network policies to restrict pod-to-pod communication.

**Technical Spec:** [Security Controls](./technical-spec.md#security-controls)

**Acceptance Criteria:**
- [ ] Default deny-all ingress policy in petclinic namespaces
- [ ] Config Server: allow ingress from all petclinic pods on 8888
- [ ] Discovery Server: allow ingress from all petclinic pods on 8761
- [ ] API Gateway: allow ingress from ALB and from internet (via ingress controller)
- [ ] Domain services: allow ingress only from API Gateway
- [ ] Admin Server: allow ingress from specific IPs or internal only
- [ ] All services: allow egress to Config Server, Discovery Server, DNS, RDS
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-68: Review and tighten IAM policies

**Type:** Story
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 3
**Labels:** security, iam, terraform
**Blocked by:** PETPLAT-16, PETPLAT-26

**Description:**
Audit all IAM roles and policies for least privilege.

**Technical Spec:** [IRSA Roles](./technical-spec.md#irsa-roles), [Security Controls](./technical-spec.md#security-controls)

**Acceptance Criteria:**
- [ ] No wildcard (*) actions in any policy
- [ ] No wildcard (*) resources where avoidable
- [ ] EKS node role has only required managed policies
- [ ] IRSA roles scoped to specific Secrets Manager secrets/resources
- [ ] No bastion host IAM role (bastion removed from scope)
- [ ] All policies documented with justification

---

### PETPLAT-69: Enable image vulnerability scanning and review results

**Type:** Task
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 2
**Labels:** security, ecr, scanning
**Blocked by:** PETPLAT-20

**Description:**
Set up vulnerability scanning for container images. ECR Private supports scan-on-push (enabled in PETPLAT-18). Additionally, use Trivy in CI (PETPLAT-105) for early detection before push. Review scan results from both sources.

**Technical Spec:** [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] ECR scan-on-push enabled on all repositories (configured in PETPLAT-18)
- [ ] Trivy scan integrated into CI pipeline (PETPLAT-105) for pre-push scanning
- [ ] After pushing images, review ECR scan findings in AWS Console
- [ ] Critical CVEs addressed (update base image or document exception)
- [ ] Scan results review process documented

---

### PETPLAT-70: Run Trivy scan on Docker images

**Type:** Task
**Priority:** P2
**Epic:** E-13 Security
**Story Points:** 2
**Labels:** security, docker, trivy
**Blocked by:** PETPLAT-20

**Description:**
Run Trivy locally or in CI on all 8 Docker images.

**Technical Spec:** [ECR Container Registry](./technical-spec.md#ecr-container-registry), [CI/CD Pipeline](./technical-spec.md#cicd-pipeline)

**Acceptance Criteria:**
- [ ] Trivy scan run on all 8 images
- [ ] Critical findings documented
- [ ] Pipeline step added (optional) for Trivy scan
- [ ] Results compared with ECR scan-on-push findings

---

### PETPLAT-71: Security group audit — no unnecessary open ports

**Type:** Task
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 2
**Labels:** security, networking
**Blocked by:** PETPLAT-8

**Description:**
Audit all security groups for overly permissive rules.

**Technical Spec:** [Security Groups](./technical-spec.md#security-groups)

**Acceptance Criteria:**
- [ ] No security group allows 0.0.0.0/0 on SSH (port 22)
- [ ] RDS SG only allows 3306 from EKS nodes
- [ ] ALB SG only allows 80/443 from internet
- [ ] EKS node SG only allows required ports
- [ ] No bastion SG (bastion removed from scope)
- [ ] Audit findings documented

---

# EPIC E-14: Scaling & Cost Optimization (Karpenter)

**Priority:** P2
**Description:** Implement autoscaling (HPA + Karpenter for node autoscaling), spot instances for dev, and cost monitoring via CloudWatch budget alerts. Karpenter replaces Cluster Autoscaler with faster, more flexible node provisioning using NodePool and EC2NodeClass CRDs.
**Blocked by:** E-9, E-17
**Blocks:** None

---

### PETPLAT-72: Install Metrics Server on EKS

**Type:** Task
**Priority:** P1
**Epic:** E-14 Scaling & Cost (Karpenter)
**Story Points:** 2
**Labels:** k8s, scaling
**Blocked by:** PETPLAT-16

**Description:**
Install Kubernetes Metrics Server (required for HPA to work).

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] Metrics Server deployed to kube-system
- [ ] `kubectl top nodes` works
- [ ] `kubectl top pods` works
- [ ] Metrics Server stable and healthy

---

### PETPLAT-73: Install Karpenter on EKS

**Type:** Story
**Priority:** P2
**Epic:** E-14 Scaling & Cost (Karpenter)
**Story Points:** 8
**Labels:** k8s, scaling, eks, karpenter
**Blocked by:** PETPLAT-16

**Description:**
Install Karpenter for node autoscaling on EKS. Karpenter provides faster, more flexible node provisioning than Cluster Autoscaler, using NodePool and EC2NodeClass CRDs. Includes SQS interruption queue and EventBridge rules for spot instance handling.

**Technical Spec:** [Karpenter Node Autoscaling](./technical-spec.md#karpenter-node-autoscaling), [IRSA Roles](./technical-spec.md#irsa-roles)

**Acceptance Criteria:**
- [ ] Karpenter controller deployed to `kube-system` namespace
- [ ] IRSA role for Karpenter with required EC2, EKS, IAM, SQS, and pricing permissions
- [ ] Karpenter instance profile created for provisioned nodes
- [ ] SQS interruption queue created for spot instance handling
- [ ] EventBridge rules configured: spot interruption, rebalance recommendation, instance state change, health events
- [ ] NodePool CRD created with resource limits (CPU, memory)
- [ ] EC2NodeClass CRD created with AMI family, subnet selector, security group selector
- [ ] Tested: scale up (create pods beyond current capacity) → Karpenter provisions new node
- [ ] Tested: scale down (remove pods) → Karpenter consolidates/removes excess nodes
- [ ] Karpenter logs show provisioning decisions

---

### PETPLAT-74: Configure Karpenter NodePool for spot instances in dev

**Type:** Story
**Priority:** P2
**Epic:** E-14 Scaling & Cost (Karpenter)
**Story Points:** 3
**Labels:** k8s, karpenter, cost-optimization
**Blocked by:** PETPLAT-73

**Description:**
Configure Karpenter NodePool for dev environment to use spot instances, saving 60-70% on compute. Karpenter's EC2NodeClass and NodePool CRDs make spot configuration declarative.

**Technical Spec:** [Karpenter Node Autoscaling](./technical-spec.md#karpenter-node-autoscaling), [Scaling and Cost](./technical-spec.md#scaling-and-cost)

**Acceptance Criteria:**
- [ ] NodePool CRD for dev with `spec.template.spec.requirements` including `karpenter.sh/capacity-type: ["spot", "on-demand"]`
- [ ] EC2NodeClass with multiple ARM instance families: t4g.small, t4g.medium (Graviton, for spot availability)
- [ ] NodePool weight configured to prefer spot over on-demand
- [ ] Consolidation policy enabled for cost optimization
- [ ] SQS interruption queue handles spot termination gracefully
- [ ] Verified: Karpenter provisions spot instances when scaling up

---

### PETPLAT-75: Create CloudWatch budget alerts

**Type:** Story
**Priority:** P2
**Epic:** E-14 Scaling & Cost (Karpenter)
**Story Points:** 3
**Labels:** terraform, cost-optimization, cloudwatch
**Blocked by:** PETPLAT-5

**Description:**
Set up AWS Budget alerts to notify when spending exceeds thresholds.

**Technical Spec:** [Scaling and Cost](./technical-spec.md#scaling-and-cost)

**Acceptance Criteria:**
- [ ] Terraform resource for AWS Budget
- [ ] Monthly budget threshold configurable (e.g., $100 per environment)
- [ ] Alert at 50%, 80%, 100% of budget
- [ ] Email notification to configurable address
- [ ] `terraform validate` passes

---

### PETPLAT-76: Document cost breakdown

**Type:** Task
**Priority:** P2
**Epic:** E-14 Scaling & Cost (Karpenter)
**Story Points:** 2
**Labels:** documentation, cost
**Blocked by:** PETPLAT-16, PETPLAT-26

**Description:**
Document the estimated monthly cost of the full stack.

**Technical Spec:** [Scaling and Cost](./technical-spec.md#scaling-and-cost)

**Acceptance Criteria:**
- [ ] Cost table in docs: EKS control plane, EC2 nodes, RDS, ALB, S3, data transfer (no NAT — intentional)
- [ ] Dev vs prod cost comparison
- [ ] Cost optimization recommendations
- [ ] Added to docs/architecture.md or separate docs/cost.md

---

# EPIC E-15: Documentation & Runbooks

**Priority:** P1
**Description:** Create operational documentation: architecture docs, operations runbook, incident playbook, onboarding guide, and ADRs.
**Blocked by:** All other epics (should finalize last, but can start early)
**Blocks:** None

---

### PETPLAT-77: Create architecture document

**Type:** Story
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 3
**Labels:** documentation
**Blocked by:** PETPLAT-16, PETPLAT-26

**Description:**
Document the infrastructure architecture.

**Technical Spec:** [General Project Parameters](./technical-spec.md#general-project-parameters), [Application Services](./technical-spec.md#application-services)

**Acceptance Criteria:**
- [ ] `docs/architecture.md`
- [ ] Infrastructure diagram (AWS resources and their relationships)
- [ ] Service topology diagram (8 services and their connections)
- [ ] Network diagram (VPC, subnets, routing, security groups)
- [ ] Technology decisions and rationale
- [ ] Environment differences (dev vs prod)

---

### PETPLAT-78: Create operations runbook

**Type:** Story
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 5
**Labels:** documentation, operations
**Blocked by:** PETPLAT-48

**Description:**
Create the day-2 operations runbook.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests)

**Acceptance Criteria:**
- [ ] `docs/runbook.md`
- [ ] How to: restart a service (`kubectl rollout restart`)
- [ ] How to: scale a service (manual and HPA)
- [ ] How to: rollback a deployment
- [ ] How to: access logs (Loki in Grafana Explore, kubectl logs)
- [ ] How to: connect to RDS (via debug pod: `kubectl run -it debug --image=mysql:8`)
- [ ] How to: update EKS version
- [ ] How to: rotate secrets
- [ ] How to: run terraform plan/apply safely
- [ ] How to: destroy and recreate the stack
- [ ] Each procedure: command, expected output, verification step

---

### PETPLAT-79: Create incident playbook

**Type:** Story
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 3
**Labels:** documentation, operations
**Blocked by:** PETPLAT-48

**Description:**
Document common failure scenarios and their resolution.

**Technical Spec:** [Application Services](./technical-spec.md#application-services)

**Acceptance Criteria:**
- [ ] `docs/incident-playbook.md`
- [ ] Scenario: Pod in CrashLoopBackOff — diagnosis, fix
- [ ] Scenario: Service not registering with Eureka — diagnosis, fix
- [ ] Scenario: Database connection failures — diagnosis, fix
- [ ] Scenario: Image pull errors from ECR — diagnosis, fix
- [ ] Scenario: Node not ready — diagnosis, fix
- [ ] Scenario: High latency / timeouts — diagnosis, fix
- [ ] Each scenario: symptoms, diagnosis commands, resolution steps

---

### PETPLAT-80: Create onboarding guide

**Type:** Story
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 3
**Labels:** documentation
**Blocked by:** PETPLAT-48

**Description:**
Create a guide that gets a new engineer productive in ≤ 90 minutes.

**Technical Spec:** [General Project Parameters](./technical-spec.md#general-project-parameters), [Application Services](./technical-spec.md#application-services)

**Acceptance Criteria:**
- [ ] `docs/onboarding.md`
- [ ] Prerequisites checklist (tools, access, accounts)
- [ ] Step-by-step: clone, install tools, configure AWS, connect to cluster
- [ ] Step-by-step: view the running app, check dashboards, read logs
- [ ] Step-by-step: make a change, deploy, verify
- [ ] Key contacts and escalation paths
- [ ] Estimated time per section

---

### PETPLAT-81: Create Architecture Decision Records (ADRs)

**Type:** Story
**Priority:** P2
**Epic:** E-15 Documentation
**Story Points:** 3
**Labels:** documentation, adr
**Blocked by:** None

**Description:**
Create ADRs for key architecture decisions made during the project.

**Technical Spec:** [ADR Index](./technical-spec.md#adr-index)

**Acceptance Criteria:**
- [ ] `docs/adr/0001-public-subnets.md` — all-public subnet design (no NAT Gateway)
- [ ] `docs/adr/0002-eks-over-ecs.md` — why EKS
- [ ] `docs/adr/0003-shared-rds.md` — shared RDS instance for all services
- [ ] `docs/adr/0004-plain-yaml-over-helm.md` — original plain K8s YAML choice (superseded by ADR-0007)
- [ ] `docs/adr/0005-github-actions-oidc.md` — GitHub Actions with OIDC federation
- [ ] `docs/adr/0006-single-az-rds.md` — single-AZ RDS for both environments
- [ ] `docs/adr/0007-helm-over-plain-yaml.md` — Helm with generic chart (supersedes ADR-0004)
- [ ] `docs/adr/0008-argocd-gitops.md` — ArgoCD for GitOps CD
- [ ] `docs/adr/0009-ecr-private.md` — ECR Private (production-correct pattern)
- [ ] `docs/adr/0010-secrets-manager.md` — Secrets Manager for secrets storage
- [ ] `docs/adr/0011-loki-over-cloudwatch.md` — in-cluster logging (Loki) over CloudWatch Logs
- [ ] Each ADR: Status, Context, Decision, Consequences

---

### PETPLAT-82: Create CLAUDE.md for petclinic-platform repo

**Type:** Task
**Priority:** P0
**Epic:** E-0 Claude Code Setup
**Story Points:** 3
**Labels:** claude, foundation
**Blocked by:** None

**Description:**
Create a CLAUDE.md in petclinic-platform that gives Claude Code full context about the infrastructure repo. This is the first file created — it establishes conventions before any infrastructure code is written.

**Acceptance Criteria:**
- [ ] `CLAUDE.md` at petclinic-platform root (< 200 lines)
- [ ] Repo purpose and directory layout
- [ ] Terraform conventions (module pattern, naming, state, tags)
- [ ] K8s manifest conventions (labels, probes, resources, secrets)
- [ ] Security rules (non-negotiable, 8 rules)
- [ ] AWS environment details (dev vs prod table)
- [ ] Application services table (8 services, ports, MySQL needs)
- [ ] MCP servers documented
- [ ] Does NOT duplicate workspace-level CLAUDE.md (app details)

---

---

# Additional Stories (Gap Analysis — from PO/Architect/Lead Dev review)

The following stories were identified during the backlog review session to close gaps for a true production-ready deployment.

---

### ~~PETPLAT-83: Define AWS resource tagging strategy~~ *(Removed — redundant with PETPLAT-5 which already covers `default_tags` and tag propagation)*

---

### PETPLAT-84: Manage EKS add-ons via Terraform

**Type:** Story
**Priority:** P1
**Epic:** E-3 EKS Cluster
**Story Points:** 3
**Labels:** terraform, eks, addons
**Blocked by:** PETPLAT-12

**Description:**
Manage EKS managed add-ons (CoreDNS, kube-proxy, vpc-cni, **EBS CSI Driver**) via Terraform with pinned versions. This ensures add-ons are versioned, reproducible, and upgraded deliberately. The EBS CSI Driver is required for PersistentVolumes used by Prometheus and Grafana.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster), [IRSA Roles](./technical-spec.md#irsa-roles)

**Acceptance Criteria:**
- [ ] `aws_eks_addon` resources for: coredns, kube-proxy, vpc-cni, **aws-ebs-csi-driver**
- [ ] IRSA role for EBS CSI Driver with `AmazonEBSCSIDriverPolicy` attached
- [ ] Add-on versions pinned (not `latest`)
- [ ] Resolve conflicts strategy: OVERWRITE (for initial setup)
- [ ] Add-ons updated as part of EKS module
- [ ] `terraform validate` passes
- [ ] Documented: how to upgrade add-on versions

---

### PETPLAT-85: Build and push Docker images to ECR (initial)

**Type:** Story
**Priority:** P0
**Epic:** E-4 Container Registry (ECR)
**Story Points:** 3
**Labels:** docker, ecr, deployment
**Blocked by:** PETPLAT-20

**Description:**
Perform the first-time manual build of all 8 Docker images from the application repo and push them to ECR. This is needed before K8s manifests can be deployed (images must exist in ECR). CI will handle subsequent builds.

**Technical Spec:** [Docker Build](./technical-spec.md#docker-build), [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] Application repo cloned locally
- [ ] `./mvnw clean install -P buildDocker` succeeds (all 8 images built)
- [ ] ECR login successful: `aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin {account}.dkr.ecr.eu-central-1.amazonaws.com`
- [ ] All 8 images tagged with initial version (e.g., `v1.0.0` or commit SHA)
- [ ] All 8 images pushed to ECR (`{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/{service}:{tag}`)
- [ ] Verified: images visible in AWS ECR Console
- [ ] Documented: the build and push commands for reference

---

### PETPLAT-86: Create reusable smoke test script

**Type:** Story
**Priority:** P1
**Epic:** E-8 K8s Base Manifests
**Story Points:** 3
**Labels:** scripts, testing, verification
**Blocked by:** PETPLAT-48

**Description:**
Create a smoke test script that validates all 8 services are running, healthy, and interconnected. Used after every deployment (manual, CI/CD, or disaster recovery).

**Technical Spec:** [Application Services](./technical-spec.md#application-services)

**Acceptance Criteria:**
- [ ] `scripts/smoke-test.sh` created
- [ ] Accepts namespace as parameter
- [ ] Checks: all 8 deployments have desired replicas ready
- [ ] Checks: Config Server /actuator/health returns UP
- [ ] Checks: Discovery Server /eureka/apps shows all services registered
- [ ] Checks: API Gateway can route to each domain service
- [ ] Checks: customers/visits/vets services can connect to RDS (create + read a test record via API)
- [ ] Returns exit code 0 on success, 1 on failure
- [ ] Output: clear pass/fail per service with error details
- [ ] Runs from within the cluster (kubectl exec) or locally via kubectl

---

### PETPLAT-87: Implement image tag update mechanism for GitOps

**Type:** Task
**Priority:** P0
**Epic:** E-10 CI Pipeline
**Story Points:** 3
**Labels:** cicd, gitops, helm
**Blocked by:** PETPLAT-49

**Description:**
Define and implement the mechanism for how the CI pipeline updates Helm values files with the new image tag (commit SHA). ArgoCD detects the Git change and deploys. Options: yq for YAML editing, sed replacement, or custom script.

**Technical Spec:** [CI/CD Pipeline](./technical-spec.md#cicd-pipeline), [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd)

**Acceptance Criteria:**
- [ ] Mechanism chosen and documented (ADR or inline) — yq recommended for YAML editing
- [ ] CI pipeline can update image tag in `helm-values/{service}.yaml` files
- [ ] Image tag is the commit SHA (matches what was pushed to ECR)
- [ ] CI commits and pushes the updated values files to Git
- [ ] ArgoCD detects the commit and syncs (dev: auto-sync, prod: manual sync)
- [ ] No `kubectl apply` in CI pipeline — GitOps only
- [ ] Tested: CI updates tag → ArgoCD deploys correct image

---

### PETPLAT-88: Add Pod Disruption Budgets for prod

**Type:** Story
**Priority:** P1
**Epic:** E-9 K8s Overlays
**Story Points:** 2
**Labels:** k8s, prod, availability
**Blocked by:** PETPLAT-46

**Description:**
Add PodDisruptionBudgets (PDBs) for prod to ensure minimum availability during node drains, rolling updates, and cluster upgrades.

**Technical Spec:** [Kubernetes Overlays](./technical-spec.md#kubernetes-overlays)

**Acceptance Criteria:**
- [ ] PDB for each service in prod overlay
- [ ] Config Server: minAvailable=1
- [ ] Discovery Server: minAvailable=1
- [ ] API Gateway: minAvailable=1
- [ ] Domain services (customers, visits, vets): minAvailable=1
- [ ] `kubectl apply --dry-run=client` passes
- [ ] Tested: node drain respects PDB (doesn't evict last pod)

---

### PETPLAT-89: Add resource quotas and limit ranges per namespace

**Type:** Story
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 3
**Labels:** k8s, security, governance
**Blocked by:** PETPLAT-38

**Description:**
Add ResourceQuotas and LimitRanges to petclinic namespaces to prevent runaway resource consumption and enforce resource requests on all pods.

**Technical Spec:** [Kubernetes Overlays](./technical-spec.md#kubernetes-overlays)

**Acceptance Criteria:**
- [ ] ResourceQuota per namespace: max CPU, max memory, max pods
- [ ] Dev namespace: lower limits (e.g., 8 CPU, 16Gi memory, 30 pods)
- [ ] Prod namespace: higher limits (e.g., 32 CPU, 64Gi memory, 80 pods)
- [ ] LimitRange: default requests and limits for containers that don't specify them
- [ ] Verified: pod without resource requests gets default applied
- [ ] `kubectl apply --dry-run=client` passes

---

### PETPLAT-90: Disaster recovery test — full teardown and rebuild

**Type:** Story
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 5
**Labels:** operations, disaster-recovery, verification
**Blocked by:** PETPLAT-48, PETPLAT-78

**Description:**
Execute a full `terraform destroy` of the dev environment and rebuild from scratch to prove the IaC is complete and the stack can be recreated. Document any manual steps found.

**Technical Spec:** [Terraform State Backend](./technical-spec.md#terraform-state-backend), [Terraform Modules](./technical-spec.md#terraform-modules)

**Acceptance Criteria:**
- [ ] `terraform destroy` completes for dev environment
- [ ] All AWS resources confirmed deleted (no orphans)
- [ ] `terraform apply` recreates the full stack
- [ ] K8s manifests re-deployed
- [ ] Smoke test passes on the rebuilt stack
- [ ] Any manual steps required are documented (and ideally automated)
- [ ] Time to rebuild documented (target: < 60 minutes)
- [ ] Findings added to runbook

---

### PETPLAT-91: Define EKS version upgrade strategy

**Type:** Story
**Priority:** P2
**Epic:** E-15 Documentation
**Story Points:** 3
**Labels:** eks, operations, documentation
**Blocked by:** PETPLAT-16

**Description:**
Document the EKS cluster upgrade strategy. EKS Kubernetes versions go end-of-life regularly. The team needs a documented process for upgrading.

**Technical Spec:** [EKS Cluster](./technical-spec.md#eks-cluster)

**Acceptance Criteria:**
- [ ] Upgrade strategy documented in docs/runbook.md or docs/adr/
- [ ] Steps: check release notes → upgrade add-ons → upgrade control plane → upgrade node groups
- [ ] Pre-upgrade checklist: check deprecation warnings, test in dev first, verify PDBs
- [ ] Add-on compatibility matrix documented
- [ ] Rollback plan: what to do if upgrade fails
- [ ] Schedule: how often to check for new versions

---

### PETPLAT-92: Terraform state management operations guide

**Type:** Task
**Priority:** P2
**Epic:** E-15 Documentation
**Story Points:** 2
**Labels:** terraform, operations, documentation
**Blocked by:** PETPLAT-5

**Description:**
Document Terraform state management procedures for common operational scenarios.

**Technical Spec:** [Terraform State Backend](./technical-spec.md#terraform-state-backend)

**Acceptance Criteria:**
- [ ] Documented in docs/runbook.md or separate docs/terraform-ops.md
- [ ] How to: view current state (`terraform state list`)
- [ ] How to: import an existing resource (`terraform import`)
- [ ] How to: remove a resource from state without destroying (`terraform state rm`)
- [ ] How to: move a resource between modules (`terraform state mv`)
- [ ] How to: recover from state corruption (S3 versioning rollback)
- [ ] How to: handle state lock stuck (DynamoDB lock force-unlock)
- [ ] Warning: when NOT to use these commands

---

---

# Additional Stories (Production Readiness & Handover Audit — Session 3)

The following stories were identified during a comprehensive end-to-end audit to ensure the platform is fully production-ready and can be handed over to an internal team.

---

### PETPLAT-97: Create monitoring and alerting guide

**Type:** Task
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 3
**Labels:** documentation, observability, handover
**Blocked by:** PETPLAT-55, PETPLAT-58

**Description:**
Create a comprehensive monitoring and alerting guide for the internal team. This document consolidates what is monitored, all alert rules and thresholds, notification routing, on-call procedures, and how to modify alerts/dashboards.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] `docs/monitoring-alerting-guide.md` created
- [ ] Lists all Prometheus alert rules with thresholds and severity
- [ ] Documents notification channels (email, Slack, PagerDuty if configured)
- [ ] Documents alert routing: who gets paged for which alert
- [ ] Instructions: how to silence/acknowledge alerts
- [ ] Instructions: how to add new alerts or modify existing ones
- [ ] Grafana dashboard access instructions (URL, credentials, key dashboards)
- [ ] Loki log streams in Grafana Explore — how to query using LogQL

---

### PETPLAT-98: Create secret rotation procedures

**Type:** Task
**Priority:** P1
**Epic:** E-7 Secrets Management (Secrets Manager)
**Story Points:** 3
**Labels:** secrets-manager, operations, security, handover
**Blocked by:** PETPLAT-23, PETPLAT-34

**Description:**
Document and implement secret rotation procedures for all managed Secrets Manager secrets. Secrets Manager provides native rotation for RDS credentials. For non-RDS secrets, document manual rotation procedures.

**Technical Spec:** [Secrets Management](./technical-spec.md#secrets-management)

**Acceptance Criteria:**
- [ ] `docs/secret-rotation.md` created (or detailed section in runbook)
- [ ] RDS master password: enable Secrets Manager automatic rotation (30-day schedule) or document manual rotation
- [ ] OpenAI API key: manual rotation procedure documented (update Secrets Manager secret, ESO syncs to K8s)
- [ ] ESO refresh interval documented (how quickly pods get updated secrets from Secrets Manager)
- [ ] Pod restart requirements after rotation documented
- [ ] Verification steps: how to confirm rotation succeeded
- [ ] Rotation schedule/policy documented
- [ ] Tested: RDS rotation works and services reconnect

---

### PETPLAT-99: Create disaster recovery plan

**Type:** Task
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 5
**Labels:** documentation, disaster-recovery, handover
**Blocked by:** PETPLAT-90

**Description:**
Create a formal disaster recovery plan document with RTO/RPO definitions, backup strategy, recovery procedures, and DR test schedule. Goes beyond PETPLAT-90 (which is a one-time test) to provide a living DR document for the team.

**Technical Spec:** [RDS Database](./technical-spec.md#rds-database), [Terraform State Backend](./technical-spec.md#terraform-state-backend), [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] `docs/disaster-recovery.md` created
- [ ] RTO/RPO targets defined (e.g., RTO: 60 min, RPO: 1 hour for RDS)
- [ ] Data backup strategy: RDS automated backups, S3 state versioning, ECR image retention (lifecycle policies)
- [ ] Recovery procedures: step-by-step for full-stack rebuild
- [ ] RDS point-in-time recovery (PITR) procedure
- [ ] Terraform state recovery from S3 versioning
- [ ] Single-region acknowledged; multi-region failover documented as future enhancement
- [ ] Communication plan during outage (who to notify, status page)
- [ ] DR test schedule: quarterly test recommended
- [ ] Lessons learned from PETPLAT-90 DR test incorporated

---

### PETPLAT-100: Create compliance checklist

**Type:** Task
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 3
**Labels:** security, compliance, handover
**Blocked by:** PETPLAT-66, PETPLAT-68

**Description:**
Create a consolidated compliance checklist documenting all security controls, encryption, access control, audit logging, and data protection measures. This serves as a handover artifact and ongoing compliance reference.

**Technical Spec:** [Security Controls](./technical-spec.md#security-controls)

**Acceptance Criteria:**
- [ ] `docs/compliance-checklist.md` created
- [ ] Encryption at rest inventory: RDS (KMS), EBS (default encryption), S3 (SSE), Secrets Manager (KMS)
- [ ] Encryption in transit: TLS at ALB, internal communication status documented
- [ ] IAM roles inventory with permission scope for each
- [ ] K8s RBAC configuration summary
- [ ] Audit logging: CloudTrail status, EKS audit logs, log retention
- [ ] Data classification: what is PII, where stored, how protected
- [ ] GDPR considerations: eu-central-1 data residency noted
- [ ] Vulnerability scanning schedule (Checkov, Trivy in CI, ECR scan-on-push)
- [ ] Remediation SLAs: Critical (24h), High (72h), Medium (1 week), Low (next sprint)

---

### PETPLAT-101: Enforce Pod Security Standards

**Type:** Story
**Priority:** P1
**Epic:** E-13 Security
**Story Points:** 3
**Labels:** k8s, security
**Blocked by:** PETPLAT-38

**Description:**
Enable Pod Security Admission (PSA) at the namespace level and set SecurityContext on all deployments to enforce pod security best practices.

**Technical Spec:** [Kubernetes Manifests](./technical-spec.md#kubernetes-manifests), [Security Controls](./technical-spec.md#security-controls)

**Acceptance Criteria:**
- [ ] PSA labels applied to petclinic-linkerd, petclinic-istio, petclinic-cilium namespaces (enforce: baseline, warn: restricted)
- [ ] All Deployments in base manifests set SecurityContext: runAsNonRoot: true
- [ ] All containers: readOnlyRootFilesystem: true (where possible — Spring Boot may need /tmp writable)
- [ ] All containers: drop ALL capabilities, add only NET_BIND_SERVICE if needed
- [ ] No privileged containers
- [ ] Verified: pods start successfully with security constraints
- [ ] Documented: what PSA mode is enforced and why

---

### PETPLAT-102: Create load testing framework

**Type:** Story
**Priority:** P1
**Epic:** E-14 Scaling & Cost (Karpenter)
**Story Points:** 5
**Labels:** testing, performance, capacity
**Blocked by:** PETPLAT-48

**Description:**
Create load test scripts and run baseline performance tests against the dev environment. Results feed into capacity planning.

**Technical Spec:** [Application Services](./technical-spec.md#application-services), [Scaling and Cost](./technical-spec.md#scaling-and-cost)

**Acceptance Criteria:**
- [ ] Load testing tool selected (k6 recommended for simplicity)
- [ ] Load test scripts created in `scripts/load-tests/` for key API flows
- [ ] Scenarios: list owners, create visit, get vets, API gateway routing
- [ ] Baseline results documented: max RPS, p99 latency at target load, resource utilization
- [ ] Bottlenecks identified and documented
- [ ] Capacity recommendations: pods per service, node count, RDS IOPS

---

### PETPLAT-103: Deploy Alertmanager with notification channels

**Type:** Story
**Priority:** P1
**Epic:** E-11 Observability
**Story Points:** 3
**Labels:** k8s, observability, alerting
**Blocked by:** PETPLAT-55

**Description:**
Deploy Alertmanager alongside Prometheus to handle alert routing and notifications. Without Alertmanager, Prometheus alerts fire but nobody gets notified.

**Technical Spec:** [Observability](./technical-spec.md#observability)

**Acceptance Criteria:**
- [ ] Alertmanager deployed in the monitoring namespace
- [ ] Connected to Prometheus (alertmanager_config in Prometheus)
- [ ] At least one notification channel configured (email minimum, Slack recommended)
- [ ] Alert routing: critical alerts → immediate notification, warning → batched
- [ ] Silence/inhibition rules for maintenance windows
- [ ] Alertmanager UI accessible via port-forward or ingress
- [ ] Tested: trigger a test alert, verify notification received

---

### PETPLAT-104: Add incident escalation paths and RCA template

**Type:** Task
**Priority:** P1
**Epic:** E-15 Documentation
**Story Points:** 2
**Labels:** documentation, incident-response, handover
**Blocked by:** PETPLAT-79

**Description:**
Extend the incident playbook (PETPLAT-79) with severity classification, escalation tiers, contact information, and a post-incident review (RCA) template.

**Technical Spec:** [Application Services](./technical-spec.md#application-services)

**Acceptance Criteria:**
- [ ] Severity classification added: SEV1 (service down), SEV2 (degraded), SEV3 (minor issue)
- [ ] Escalation tiers: L1 (on-call engineer), L2 (senior engineer), L3 (architect/vendor)
- [ ] Contact information template (names, roles, phone, email — placeholder format)
- [ ] Response time targets per severity: SEV1 (15 min), SEV2 (1 hour), SEV3 (next business day)
- [ ] Post-incident review template: timeline, root cause, contributing factors, action items, prevention
- [ ] Communication template: status update format for stakeholders

---

### PETPLAT-105: Add CI vulnerability scanning gate

**Type:** Story
**Priority:** P1
**Epic:** E-10 CI Pipeline
**Story Points:** 3
**Labels:** ci, security
**Blocked by:** PETPLAT-49

**Description:**
Add a vulnerability scanning step to the CI build pipeline that fails the build if CRITICAL CVEs are detected. Uses Trivy to scan Docker images before pushing to ECR. This complements ECR's native scan-on-push by catching issues before push.

**Technical Spec:** [CI/CD Pipeline](./technical-spec.md#cicd-pipeline), [ECR Container Registry](./technical-spec.md#ecr-container-registry)

**Acceptance Criteria:**
- [ ] Trivy scan step added to build-push pipeline after Docker build, before pushing to ECR
- [ ] Pipeline fails (exit 1) if CRITICAL vulnerabilities are found
- [ ] HIGH vulnerabilities generate warnings but do not block
- [ ] Scan results saved as pipeline artifact for review
- [ ] Allowlist mechanism for known/accepted CVEs (trivy.yaml or --ignorefile)
- [ ] Documented: how to review scan results, how to add to allowlist

---

### ~~PETPLAT-106: Implement Terraform drift detection~~ *(Removed — Day-2 operations task, requires CI pipeline from Section 11. Covered naturally in Section 18 lecture 18.4)*

---

# EPIC E-16: Helm Charts

**Priority:** P0
**Description:** Create a generic Helm chart for Petclinic microservices and per-service/per-environment values files. All 8 services share the same chart template with service-specific configuration in values files. This replaces raw K8s YAML + Kustomize overlays with a more maintainable Helm-based approach.
**Blocked by:** E-8 (base manifests define what gets templated), E-9 (overlay definitions inform values structure)
**Blocks:** E-17 (ArgoCD deploys Helm charts)

---

### PETPLAT-107: Create generic Helm chart for Petclinic services

**Type:** Story
**Priority:** P0
**Epic:** E-16 Helm Charts
**Story Points:** 8
**Labels:** helm, k8s
**Blocked by:** PETPLAT-38 through PETPLAT-44

**Description:**
Create a generic, reusable Helm chart at `helm/petclinic-service/` that can deploy any of the 8 Petclinic microservices. The chart includes templates for Deployment, Service, ConfigMap, ServiceAccount, HPA, and PDB. Per-service differences (ports, env vars, probes, secrets) are driven by values files.

**Technical Spec:** [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] Chart at `helm/petclinic-service/` with Chart.yaml, values.yaml, templates/
- [ ] Templates: deployment.yaml, service.yaml, configmap.yaml, serviceaccount.yaml, hpa.yaml, pdb.yaml
- [ ] HPA and PDB templates are conditional (only rendered when enabled in values)
- [ ] Default values.yaml with sensible defaults for all 8 services
- [ ] Supports: image repository/tag, replicas, resources, ports, env vars, probes, secrets
- [ ] Supports: initContainers (for service dependency ordering)
- [ ] Labels follow Kubernetes recommended labels (app.kubernetes.io/*)
- [ ] `helm lint helm/petclinic-service/` passes
- [ ] `helm template` renders valid YAML for each service

---

### PETPLAT-108: Create per-service Helm values files

**Type:** Story
**Priority:** P0
**Epic:** E-16 Helm Charts
**Story Points:** 5
**Labels:** helm, k8s
**Blocked by:** PETPLAT-107

**Description:**
Create per-service values files at `helm-values/{service}.yaml` for all 8 Petclinic services. Each values file contains service-specific configuration: image name, port, environment variables, probe paths, secret references, and resource requests.

**Technical Spec:** [Helm Charts](./technical-spec.md#helm-charts), [Application Services](./technical-spec.md#application-services)

**Acceptance Criteria:**
- [ ] Values files created for all 8 services: `helm-values/config-server.yaml`, `helm-values/discovery-server.yaml`, `helm-values/api-gateway.yaml`, `helm-values/customers-service.yaml`, `helm-values/visits-service.yaml`, `helm-values/vets-service.yaml`, `helm-values/genai-service.yaml`, `helm-values/admin-server.yaml`
- [ ] Each file specifies: image repo (`{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic-{env}/{service}`), image tag, container port, service port
- [ ] Database services (customers, visits, vets): Spring profiles `docker,mysql`, datasource URL, secret references for RDS credentials
- [ ] GenAI service: secret reference for OpenAI API key from Secrets Manager (via ESO)
- [ ] Config Server: GIT_REPO URL for config
- [ ] All services: CONFIG_SERVER_URL, readiness/liveness probe paths
- [ ] `helm template` with each values file renders correct manifests

---

### PETPLAT-109: Create per-mesh Helm values files

**Type:** Story
**Priority:** P0
**Epic:** E-16 Helm Charts
**Story Points:** 3
**Labels:** helm, k8s, environments
**Blocked by:** PETPLAT-107, PETPLAT-45

**Description:**
Create per-cluster values files at `helm-values/linkerd.yaml`, `helm-values/istio.yaml`, and `helm-values/cilium.yaml`. These set the correct namespace, mesh-specific pod annotations/labels, and any replica or resource differences for each service mesh cluster.

**Technical Spec:** [Helm Charts](./technical-spec.md#helm-charts), [Kubernetes Overlays](./technical-spec.md#kubernetes-overlays)

**Acceptance Criteria:**
- [ ] `helm-values/linkerd.yaml` — namespace: petclinic-linkerd, `podAnnotations.linkerd.io/inject: enabled`, 1 replica
- [ ] `helm-values/istio.yaml` — namespace: petclinic-istio, no sidecar annotations (ambient mode uses namespace label), 1 replica
- [ ] `helm-values/cilium.yaml` — namespace: petclinic-cilium, no mesh annotations required, 1 replica
- [ ] Values merged with per-service values when deploying: `helm install -f helm-values/{service}.yaml -f helm-values/{mesh}.yaml`
- [ ] `helm template` with combined values files renders correct manifests for all three meshes

---

### PETPLAT-110: Test Helm template rendering and validate output

**Type:** Task
**Priority:** P0
**Epic:** E-16 Helm Charts
**Story Points:** 3
**Labels:** helm, testing
**Blocked by:** PETPLAT-108, PETPLAT-109

**Description:**
Validate that Helm template rendering produces correct, deployable Kubernetes manifests for all services across both environments. Run `helm template` and `kubectl apply --dry-run=client` on the output.

**Technical Spec:** [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] `helm lint helm/petclinic-service/` passes
- [ ] `helm template` renders valid YAML for each of the 8 services with linkerd values
- [ ] `helm template` renders valid YAML for each of the 8 services with istio values
- [ ] `helm template` renders valid YAML for each of the 8 services with cilium values
- [ ] `kubectl apply --dry-run=client` passes on all rendered templates
- [ ] Rendered output matches expected: correct ports, env vars, secrets, probes, replicas, mesh annotations
- [ ] Script created at `scripts/validate-helm.sh` to automate this validation for all services and mesh environments

---

### PETPLAT-111: Document Helm chart usage and conventions

**Type:** Task
**Priority:** P0
**Epic:** E-16 Helm Charts
**Story Points:** 3
**Labels:** helm, documentation
**Blocked by:** PETPLAT-110

**Description:**
Document the Helm chart structure, values file conventions, and how to add a new service or modify existing ones.

**Technical Spec:** [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] Documentation in `docs/helm-guide.md` or as a section in architecture.md
- [ ] Chart structure explained: templates, values hierarchy
- [ ] How to: deploy a service manually with Helm
- [ ] How to: add a new service (create values file, add ArgoCD Application)
- [ ] How to: change resources, replicas, or environment variables
- [ ] Values merge order documented: defaults < per-service < per-environment
- [ ] Integration with ArgoCD documented (E-17)

---

---

# EPIC E-17: GitOps with ArgoCD

**Priority:** P0
**Description:** Install ArgoCD on EKS and configure GitOps-based continuous delivery for all 8 Petclinic services. ArgoCD watches the Git repo for changes to Helm values files and automatically deploys to dev (auto-sync) or awaits manual approval for prod (manual sync). This replaces `kubectl apply` in CI/CD pipelines with a proper GitOps pattern.
**Blocked by:** E-3 (EKS), E-16 (Helm charts), E-4 (ECR)
**Blocks:** None (but E-10 CI pipeline pushes tags that ArgoCD deploys)

---

### PETPLAT-112: Install ArgoCD on EKS cluster

**Type:** Story
**Priority:** P0
**Epic:** E-17 GitOps with ArgoCD
**Story Points:** 5
**Labels:** k8s, argocd, gitops
**Blocked by:** PETPLAT-16

**Description:**
Install ArgoCD on the EKS cluster in a dedicated `argocd` namespace. Include the ArgoCD server, repo server, application controller, and Redis. Store manifests in `k8s/argocd/install/`.

**Technical Spec:** [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd)

**Acceptance Criteria:**
- [ ] ArgoCD installed in `argocd` namespace using official manifests
- [ ] Installation manifests stored at `k8s/argocd/install/`
- [ ] ArgoCD server, repo-server, application-controller, Redis all running and healthy
- [ ] ArgoCD CLI (`argocd`) can connect to the cluster
- [ ] ArgoCD UI accessible via port-forward (`kubectl port-forward svc/argocd-server -n argocd 8443:443`)
- [ ] Initial admin password retrieved and documented
- [ ] ArgoCD version pinned to a specific release

---

### PETPLAT-113: Create ArgoCD Application CRDs for linkerd cluster

**Type:** Story
**Priority:** P0
**Epic:** E-17 GitOps with ArgoCD
**Story Points:** 5
**Labels:** k8s, argocd, gitops, linkerd
**Blocked by:** PETPLAT-112, PETPLAT-107, PETPLAT-108, PETPLAT-109

**Description:**
Create ArgoCD Application CRDs for all 8 Petclinic services targeting the `petclinic-linkerd` cluster. Auto-sync enabled — any Helm values change in Git triggers automatic deployment.

**Technical Spec:** [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd), [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] ArgoCD Application manifests at `k8s/argocd/applications/linkerd/` (one per service)
- [ ] Each Application points to the Helm chart at `helm/petclinic-service/`
- [ ] Each Application uses values files: `helm-values/{service}.yaml` + `helm-values/linkerd.yaml`
- [ ] Sync policy: `automated` with `selfHeal: true` and `prune: true`
- [ ] Destination server: `petclinic-linkerd` EKS cluster API endpoint
- [ ] Destination namespace: `petclinic-linkerd`
- [ ] Source repo: petclinic-platform Git URL
- [ ] All 8 applications visible and synced in ArgoCD UI
- [ ] Verified: push a tag change → ArgoCD auto-syncs → new image deployed to linkerd cluster

---

### PETPLAT-114: Create ArgoCD Application CRDs for istio and cilium clusters

**Type:** Story
**Priority:** P0
**Epic:** E-17 GitOps with ArgoCD
**Story Points:** 5
**Labels:** k8s, argocd, gitops, istio, cilium
**Blocked by:** PETPLAT-113

**Description:**
Create ArgoCD Application CRDs for the istio and cilium clusters, following the same pattern as PETPLAT-113. Each cluster is registered as a separate ArgoCD destination cluster. This completes the three-cluster GitOps setup.

**Technical Spec:** [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd), [Helm Charts](./technical-spec.md#helm-charts)

**Acceptance Criteria:**
- [ ] ArgoCD Application manifests at `k8s/argocd/applications/istio/` (one per service)
- [ ] ArgoCD Application manifests at `k8s/argocd/applications/cilium/` (one per service)
- [ ] Istio apps: values `helm-values/{service}.yaml` + `helm-values/istio.yaml`, namespace `petclinic-istio`
- [ ] Cilium apps: values `helm-values/{service}.yaml` + `helm-values/cilium.yaml`, namespace `petclinic-cilium`
- [ ] Sync policy: `automated` with `selfHeal: true` and `prune: true` on all
- [ ] All three clusters registered in ArgoCD (`argocd cluster add`)
- [ ] 24 total Application CRDs (8 services × 3 clusters), all visible and healthy in ArgoCD UI

---

### PETPLAT-115: Configure ArgoCD RBAC and access

**Type:** Task
**Priority:** P0
**Epic:** E-17 GitOps with ArgoCD
**Story Points:** 3
**Labels:** argocd, security, rbac
**Blocked by:** PETPLAT-112

**Description:**
Configure ArgoCD RBAC policies, user access, and security settings. Restrict who can sync prod applications.

**Technical Spec:** [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd)

**Acceptance Criteria:**
- [ ] ArgoCD RBAC configured via argocd-rbac-cm ConfigMap
- [ ] Admin role can manage all applications and settings
- [ ] Developer role can view all applications and sync any cluster (all are auto-sync lab clusters)
- [ ] Admin role has full management access including ArgoCD settings and cluster registration
- [ ] Default admin password changed from initial auto-generated value
- [ ] SSO integration documented as optional future enhancement
- [ ] RBAC configuration stored at `k8s/argocd/argocd-rbac-cm.yaml`

---

### PETPLAT-116: Test GitOps loop end-to-end

**Type:** Task
**Priority:** P0
**Epic:** E-17 GitOps with ArgoCD
**Story Points:** 3
**Labels:** argocd, gitops, testing
**Blocked by:** PETPLAT-113, PETPLAT-114, PETPLAT-50

**Description:**
Test the complete GitOps loop: CI builds and pushes image → CI updates image tag in shared Helm values → ArgoCD detects change → ArgoCD deploys new version to all three clusters. All clusters use auto-sync.

**Technical Spec:** [GitOps with ArgoCD](./technical-spec.md#gitops-with-argocd), [CI/CD Pipeline](./technical-spec.md#cicd-pipeline)

**Acceptance Criteria:**
- [ ] GitOps loop tested on linkerd cluster: push code → CI builds → CI updates values → ArgoCD auto-syncs → new version running
- [ ] Verified the same image SHA propagates to istio and cilium clusters automatically
- [ ] Rollback tested: revert image tag in Git → ArgoCD syncs previous version on all three clusters
- [ ] ArgoCD health checks pass for all services (24 apps) after sync
- [ ] Sync history visible in ArgoCD UI per cluster
- [ ] Time from commit to running pod documented (target: < 10 min per cluster)

---

---

## Summary

| Priority | Epics | Stories/Tasks |
|----------|-------|---------------|
| P0 | Claude Code Setup, Foundation, VPC, EKS, ECR, RDS, Secrets (Secrets Manager), K8s Base, CI Pipeline, Helm Charts, GitOps (ArgoCD) | 64 |
| P1 | DNS, K8s Overlays, Observability, Security, Docs | 38 |
| P2 | Scaling & Cost (Karpenter) | 6 |
| **Total** | **17 epics (E-12 removed = 16 active)** | **108 stories/tasks** |

**Estimated total story points:** ~341
