# Technical Specification — Petclinic Platform

> **Purpose:** Single source of truth for all infrastructure values. Jira stories reference sections of this document via anchor links. Read the relevant section before implementing any story.
>
> **Architecture:** Service Mesh Comparison Platform — one shared VPC, three independent EKS clusters (Linkerd, Istio Ambient, Cilium), all running the Spring Petclinic Microservices app.

---

## Table of Contents

1. [General Project Parameters](#general-project-parameters)
2. [Terraform State Backend](#terraform-state-backend)
3. [VPC Network Design](#vpc-network-design)
4. [Security Groups](#security-groups)
5. [EKS Clusters](#eks-clusters)
6. [ECR Container Registry](#ecr-container-registry)
7. [RDS Database](#rds-database)
8. [Secrets Management](#secrets-management)
9. [DNS and Ingress](#dns-and-ingress)
10. [Application Services](#application-services)
11. [Kubernetes Manifests](#kubernetes-manifests)
12. [CI/CD Pipeline](#cicd-pipeline)
13. [Observability](#observability)
14. [IRSA Roles](#irsa-roles)
15. [Security Controls](#security-controls)
16. [Scaling and Cost](#scaling-and-cost)
17. [Docker Build](#docker-build)
18. [Terraform Modules](#terraform-modules)
19. [Helm Charts](#helm-charts)
20. [GitOps with ArgoCD](#gitops-with-argocd)
21. [Karpenter (Node Autoscaling)](#karpenter-node-autoscaling)
22. [ADR Index](#adr-index)

---

## General Project Parameters

| Parameter | Value |
|-----------|-------|
| AWS Region | `eu-central-1` |
| Availability Zones | `eu-central-1a`, `eu-central-1b` |
| Project Name | `petclinic` |
| Naming Convention | `petclinic-{mesh}-{resource}` (e.g., `petclinic-linkerd-eks`, `petclinic-shared-vpc`) |
| Environments | `shared` (VPC), `linkerd`, `istio`, `cilium` |
| Terraform Version | `>= 1.10.0` |
| AWS Provider Version | `~> 5.0` |
| Spring Boot Version | `4.0.1` |
| Spring Cloud Version | `2025.1.0` (Oakwood) |
| Java Version | `17` |

### Cluster Inventory

| Environment | Cluster Name | Service Mesh | State Key |
|-------------|-------------|--------------|-----------|
| `shared` | — (VPC only) | — | `petclinic/shared/terraform.tfstate` |
| `linkerd` | `petclinic-linkerd` | Linkerd | `petclinic/linkerd/terraform.tfstate` |
| `istio` | `petclinic-istio` | Istio Ambient | `petclinic/istio/terraform.tfstate` |
| `cilium` | `petclinic-cilium` | Cilium | `petclinic/cilium/terraform.tfstate` |

### Required Tags (All AWS Resources)

| Tag Key | Value | Purpose |
|---------|-------|---------|
| `Project` | `petclinic` | Cost allocation, resource grouping |
| `Environment` | `shared`, `linkerd`, `istio`, or `cilium` | Environment identification |
| `ManagedBy` | `terraform` | Drift detection, ownership |

Applied via `default_tags` in the AWS provider. Cluster environments additionally set:

| Tag Key | Value | Purpose |
|---------|-------|---------|
| `ServiceMesh` | `linkerd`, `istio-ambient`, or `cilium` | Service mesh differentiation for cost allocation |

---

## Terraform State Backend

| Parameter | Value |
|-----------|-------|
| Backend Type | S3 with native locking (`use_lockfile = true`) |
| S3 Bucket | `petclinic-terraform-state-bkr` |
| S3 Encryption | AES256 (SSE-S3) |
| S3 Versioning | Enabled |
| S3 Public Access | All blocked (4 settings) |
| DynamoDB Table | **None** — S3 native locking used (Terraform ≥ 1.10.0) |

### Per-Environment State Keys

| Environment | State Key | Purpose |
|-------------|-----------|---------|
| Shared | `petclinic/shared/terraform.tfstate` | VPC state (read by all cluster envs via `terraform_remote_state`) |
| Linkerd | `petclinic/linkerd/terraform.tfstate` | Linkerd cluster state |
| Istio | `petclinic/istio/terraform.tfstate` | Istio Ambient cluster state |
| Cilium | `petclinic/cilium/terraform.tfstate` | Cilium cluster state |

### Bootstrap Script

`scripts/bootstrap-state.sh` provisions the S3 bucket. It is:
- Idempotent (safe to run multiple times)
- Accepts `--region` and `--bucket` parameters
- No DynamoDB required — S3 native locking (`use_lockfile = true` in backend config)
- Run once before `terraform init` in any environment

### Backend Configuration (all environments)

```hcl
terraform {
  backend "s3" {
    bucket       = "petclinic-terraform-state-bkr"
    key          = "petclinic/{env}/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Remote State Reference (cluster environments → shared VPC)

```hcl
data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket       = var.state_bucket
    key          = "petclinic/shared/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
```

---

## VPC Network Design

### Architecture Decision

Single shared VPC used by all three EKS clusters. All-public subnet design — no NAT Gateway, no private subnets, no VPC endpoints. Security groups are the perimeter. Saves ~$35-65/month. See [ADR-0001](#adr-index).

### CIDR Allocation

| Parameter | Value |
|-----------|-------|
| VPC CIDR | `10.0.0.0/16` (65,536 IPs) |
| VPC Name | `petclinic-shared` |
| Public Subnet 1 (AZ a) | `10.0.1.0/24` (251 usable) |
| Public Subnet 2 (AZ b) | `10.0.2.0/24` (251 usable) |

### VPC Settings

| Setting | Value |
|---------|-------|
| DNS Support | `true` |
| DNS Hostnames | `true` |
| Internet Gateway | 1, attached |
| Route Table | 1 public route table, `0.0.0.0/0` → IGW |
| NAT Gateway | None (intentional) |
| VPC Endpoints | None |
| `map_public_ip_on_launch` | `true` |

### EKS Subnet Tags

Each cluster environment applies its own cluster-association tag to the shared subnets via `aws_ec2_tag` (not in the VPC module itself):

| Tag Key | Value | Applied By |
|---------|-------|------------|
| `kubernetes.io/cluster/petclinic-linkerd` | `shared` | `terraform/environments/linkerd/` |
| `kubernetes.io/cluster/petclinic-istio` | `shared` | `terraform/environments/istio/` |
| `kubernetes.io/cluster/petclinic-cilium` | `shared` | `terraform/environments/cilium/` |
| `kubernetes.io/role/elb` | `1` | VPC module (common to all clusters) |

---

## Security Groups

Each EKS cluster gets its own cluster SG and node SG (provisioned by the EKS module). The RDS and ALB SGs are provisioned in the VPC module and shared.

### EKS Cluster Security Group (per cluster)

| Rule | Type | Protocol | Port | Source |
|------|------|----------|------|--------|
| API server from nodes | Ingress | TCP | 443 | EKS Node SG (same cluster) |
| All outbound | Egress | All | All | `0.0.0.0/0` |

### EKS Node Security Group (per cluster)

| Rule | Type | Protocol | Port | Source |
|------|------|----------|------|--------|
| All from cluster SG | Ingress | All | All | EKS Cluster SG |
| Inter-node | Ingress | All | All | Self |
| Kubelet from cluster | Ingress | TCP | 10250 | EKS Cluster SG |
| NodePort from ALB | Ingress | TCP | 30000-32767 | ALB SG |
| All outbound | Egress | All | All | `0.0.0.0/0` |

### RDS Security Group (shared, in VPC module)

| Rule | Type | Protocol | Port | Source |
|------|------|----------|------|--------|
| MySQL from all cluster nodes | Ingress | TCP | 3306 | All 3 node SGs |

**Critical:** Never `0.0.0.0/0` on 3306.

### ALB Security Group (shared, in VPC module)

| Rule | Type | Protocol | Port | Source |
|------|------|----------|------|--------|
| HTTP from internet | Ingress | TCP | 80 | `0.0.0.0/0` |
| HTTPS from internet | Ingress | TCP | 443 | `0.0.0.0/0` |
| To nodes | Egress | TCP | 30000-32767 | EKS Node SGs |

---

## EKS Clusters

Three identical clusters, each in the shared VPC, differentiated by the `ServiceMesh` tag and cluster name.

### Cluster Configuration

| Parameter | linkerd | istio | cilium |
|-----------|---------|-------|--------|
| Cluster Name | `petclinic-linkerd` | `petclinic-istio` | `petclinic-cilium` |
| Kubernetes Version | `1.31` | `1.31` | `1.31` |
| API Server Endpoint | Public | Public | Public |
| Authentication Mode | `API_AND_CONFIG_MAP` | `API_AND_CONFIG_MAP` | `API_AND_CONFIG_MAP` |
| Cluster Logging | `api`, `audit`, `authenticator` | `api`, `audit`, `authenticator` | `api`, `audit`, `authenticator` |
| ServiceMesh Tag | `linkerd` | `istio-ambient` | `cilium` |

### Cluster IAM Role

| Policy | Type |
|--------|------|
| `AmazonEKSClusterPolicy` | AWS Managed |

### OIDC Provider

Created from EKS cluster identity issuer URL. Required for IRSA. One per cluster.

### Managed Node Group (identical across all 3 clusters)

| Parameter | Value |
|-----------|-------|
| Node Group Name | `{cluster_name}-nodes` |
| Instance Types | `["t4g.small"]` |
| Architecture | ARM64 (Graviton) |
| Capacity Type | `ON_DEMAND` (Graviton free trial until Dec 2026) |
| Min Size | 2 |
| Max Size | 4 |
| Desired Size | 2 |
| Disk Size | 20 GB |
| AMI Type | `AL2_ARM_64` |
| `update_config.max_unavailable` | `1` |

### Node IAM Role Policies

| Policy | Type |
|--------|------|
| `AmazonEKSWorkerNodePolicy` | AWS Managed |
| `AmazonEKS_CNI_Policy` | AWS Managed |
| `AmazonEC2ContainerRegistryReadOnly` | AWS Managed |

### EKS Managed Add-ons

| Add-on | Purpose | IRSA Required |
|--------|---------|---------------|
| `coredns` | Cluster DNS | No |
| `kube-proxy` | Network proxy | No |
| `vpc-cni` | Pod networking | No |
| `aws-ebs-csi-driver` | EBS PersistentVolumes (Prometheus, Grafana) | Yes (`AmazonEBSCSIDriverPolicy`) |

> **Note:** Cilium cluster may replace `kube-proxy` and `vpc-cni` with Cilium's own CNI. This is handled post-Terraform via Helm install. The EKS module provisions standard add-ons; service mesh installation is a separate step.

---

## ECR Container Registry

### Repository Configuration

ECR repositories are **shared across all three clusters** — all clusters run the same images for a fair comparison.

| Parameter | Value |
|-----------|-------|
| Registry Type | ECR Private |
| Terraform Resource | `aws_ecr_repository` |
| Region | `eu-central-1` |
| Tag Mutability | `MUTABLE` |
| Image Scanning | Scan-on-push enabled |
| Encryption | AES256 (default) |

### Repositories (8 total, shared across all clusters)

| Repository Name | Service | Image URI Pattern |
|-----------------|---------|-------------------|
| `petclinic/config-server` | Config Server | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/config-server:{tag}` |
| `petclinic/discovery-server` | Discovery Server | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/discovery-server:{tag}` |
| `petclinic/api-gateway` | API Gateway | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/api-gateway:{tag}` |
| `petclinic/customers-service` | Customers Service | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/customers-service:{tag}` |
| `petclinic/visits-service` | Visits Service | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/visits-service:{tag}` |
| `petclinic/vets-service` | Vets Service | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/vets-service:{tag}` |
| `petclinic/genai-service` | GenAI Service | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/genai-service:{tag}` |
| `petclinic/admin-server` | Admin Server | `{account}.dkr.ecr.eu-central-1.amazonaws.com/petclinic/admin-server:{tag}` |

### Image Tag Strategy

| Context | Tag Format | Example |
|---------|------------|---------|
| CI/CD builds | Short commit SHA (7 chars) | `a1b2c3d` |
| Never used | `latest` | — |

### Lifecycle Policies

Keep last 10 images per repository.

---

## RDS Database

### Instance Configuration

Single shared RDS instance — all three clusters connect to the same database for a fair app-level comparison (same data, same schema).

| Parameter | Value |
|-----------|-------|
| DB Identifier | `petclinic-shared-mysql` |
| Engine | MySQL 8.0 |
| Instance Class | `db.t4g.micro` |
| Multi-AZ | `false` (cost optimization) |
| Allocated Storage | 20 GB |
| Storage Type | `gp2` |
| Storage Encrypted | `true` (AWS default KMS key) |
| Backup Retention | 7 days |
| Skip Final Snapshot | `true` |
| Deletion Protection | `false` |
| Master Username | `petclinic` |
| Master Password | Generated via `random_password` |

### Parameter Group

| Parameter | Value |
|-----------|-------|
| `character_set_server` | `utf8mb4` |
| `collation_server` | `utf8mb4_unicode_ci` |

### Database Schema

Shared `petclinic` database. All three services (customers, visits, vets) use this single RDS instance, connected from whichever cluster is running the workload.

### Connection String Format

```
jdbc:mysql://petclinic-shared-mysql.{id}.eu-central-1.rds.amazonaws.com:3306/petclinic
```

---

## Secrets Management

### Secrets

| Secret Name | Type | Content | Created By |
|-------------|------|---------|------------|
| `petclinic/shared/rds-credentials` | JSON `{"username":"...","password":"..."}` | RDS master credentials | RDS module |
| `petclinic/shared/openai-api-key` | Plaintext | OpenAI API key | Secrets module |

### External Secrets Operator (ESO)

| Parameter | Value |
|-----------|-------|
| Installation | Helm chart |
| Namespace | `external-secrets` (per cluster) |
| Store Type | `ClusterSecretStore` |
| Provider | AWS Secrets Manager |
| Auth | IRSA |

### ClusterSecretStore

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-secrets-manager
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-central-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
            namespace: external-secrets
```

---

## DNS and Ingress

### ACM Certificate

| Parameter | Value |
|-----------|-------|
| Domain | `*.{domain}` (wildcard) |
| Validation Method | DNS (Route 53) |
| Region | `eu-central-1` |

### Route 53 Records

| Record | Target | Purpose |
|--------|--------|---------|
| `petclinic-linkerd.{domain}` | Linkerd cluster ALB | Linkerd workload endpoint |
| `petclinic-istio.{domain}` | Istio cluster ALB | Istio workload endpoint |
| `petclinic-cilium.{domain}` | Cilium cluster ALB | Cilium workload endpoint |

### AWS Load Balancer Controller

| Parameter | Value |
|-----------|-------|
| Installation | Helm (`aws-load-balancer-controller`) |
| Namespace | `kube-system` |
| Auth | IRSA |
| IngressClass | `alb` |

### Ingress Annotations

```yaml
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/certificate-arn: "{acm-certificate-arn}"
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
alb.ingress.kubernetes.io/ssl-redirect: "443"
alb.ingress.kubernetes.io/healthcheck-path: /actuator/health
alb.ingress.kubernetes.io/healthcheck-port: "8080"
```

---

## Application Services

### Service Inventory

| Service | Spring Name | Port | MySQL | Config Server | Discovery | Startup Order |
|---------|-------------|------|-------|---------------|-----------|---------------|
| Config Server | `config-server` | 8888 | No | Self (Git) | No | 1st |
| Discovery Server | `discovery-server` | 8761 | No | Yes | Self | 2nd |
| API Gateway | `api-gateway` | 8080 | No | Yes | Yes | 3rd+ |
| Customers Service | `customers-service` | 8081 | Yes | Yes | Yes | 3rd+ (before Visits) |
| Visits Service | `visits-service` | 8082 | Yes | Yes | Yes | After Customers |
| Vets Service | `vets-service` | 8083 | Yes | Yes | Yes | 3rd+ |
| GenAI Service | `genai-service` | 8084 | Optional | Yes | Yes | 3rd+ |
| Admin Server | `admin-server` | 9090 | No | Yes | Yes | 3rd+ |

### Spring Profiles

| Profile | Purpose |
|---------|---------|
| `docker` | Config Server URL → `config-server` (Docker DNS) |
| `mysql` | Switches to MySQL datasource |
| `production` | Required for vets-service Caffeine cache |

---

## Kubernetes Manifests

### Namespaces

| Namespace | Cluster | PSA Enforce |
|-----------|---------|-------------|
| `petclinic-linkerd` | petclinic-linkerd | `baseline` |
| `petclinic-istio` | petclinic-istio | `baseline` |
| `petclinic-cilium` | petclinic-cilium | `baseline` |

### Standard Labels (All Resources)

```yaml
app.kubernetes.io/name: "{service-name}"
app.kubernetes.io/part-of: petclinic
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/component: "{server|service|gateway|admin}"
```

### Health Probes

| Probe | Path | Port | Period | Timeout | Failure Threshold |
|-------|------|------|--------|---------|-------------------|
| Startup | `/actuator/health` | Service port | 10s | 5s | 30 |
| Readiness | `/actuator/health/readiness` | Service port | 10s | 5s | 3 |
| Liveness | `/actuator/health/liveness` | Service port | 15s | 5s | 3 |

### Resource Requests and Limits

| Service | CPU Request | CPU Limit | Memory Request | Memory Limit |
|---------|-------------|-----------|----------------|--------------|
| config-server | 100m | 500m | 128Mi | 512Mi |
| discovery-server | 100m | 500m | 128Mi | 512Mi |
| api-gateway | 200m | 1000m | 128Mi | 512Mi |
| customers-service | 100m | 500m | 128Mi | 512Mi |
| visits-service | 100m | 500m | 128Mi | 512Mi |
| vets-service | 100m | 500m | 128Mi | 512Mi |
| genai-service | 100m | 500m | 128Mi | 512Mi |
| admin-server | 100m | 500m | 128Mi | 512Mi |

### Init Containers (Startup Order)

```yaml
initContainers:
  - name: wait-for-config-server
    image: busybox:1.36
    command: ['sh', '-c', 'until wget -qO- http://config-server:8888/actuator/health; do sleep 5; done']
  - name: wait-for-discovery-server
    image: busybox:1.36
    command: ['sh', '-c', 'until wget -qO- http://discovery-server:8761/actuator/health; do sleep 5; done']
```

### SecurityContext

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
containers:
  - securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
      readOnlyRootFilesystem: false
```

---

## CI/CD Pipeline

### Architecture

| Concern | Tool |
|---------|------|
| Build & Push images | GitHub Actions (`build-push.yml`) |
| Update image tags | GitHub Actions (`update-image-tags.yml`) |
| Deploy to Kubernetes | ArgoCD (watches Git, syncs all 3 clusters) |

### OIDC Federation

| Parameter | Value |
|-----------|-------|
| OIDC Provider | `token.actions.githubusercontent.com` |
| Subject Filter | `repo:{org}/{repo}:ref:refs/heads/main` |
| IAM Role | `petclinic-github-actions-role` |
| Permissions | ECR push only |

### GitHub Secrets

| Secret | Value |
|--------|-------|
| `AWS_REGION` | `eu-central-1` |
| `AWS_ROLE_ARN` | OIDC role ARN |
| `AWS_ACCOUNT_ID` | AWS account ID |

### Build Steps

1. Checkout application repo
2. Set up JDK 17
3. Set up Docker Buildx + QEMU (ARM64 cross-compilation)
4. Configure AWS credentials (OIDC)
5. ECR login
6. Maven build: `./mvnw clean install -P buildDocker -Dcontainer.platform="linux/arm64"`
7. Trivy scan (fail on CRITICAL CVEs)
8. Tag with commit SHA (`${GITHUB_SHA::7}`)
9. Push all 8 images to ECR

### Image Tag Update

CI commits new image tags to `helm-values/{service}.yaml`. ArgoCD detects the change and syncs all three clusters.

---

## Observability

Per-cluster observability stack deployed in the `monitoring` namespace on each cluster. Enables apples-to-apples service mesh comparison using identical dashboards.

### Prometheus

| Parameter | Value |
|-----------|-------|
| Namespace | `monitoring` |
| Scrape Interval | 15s |
| Retention | 7 days |
| Storage | PersistentVolume (EBS, 10Gi) |

### Grafana

| Parameter | Value |
|-----------|-------|
| Namespace | `monitoring` |
| Datasources | Prometheus, Loki |
| Storage | PersistentVolume (EBS, 5Gi) |

#### Dashboard Set (per cluster)

| Dashboard | Purpose |
|-----------|---------|
| Service Overview | All 8 services: up/down, RPS, error rate |
| Per-Service (×8) | Request rate, error rate, p95/p99 latency |
| JVM Metrics | Heap, GC, thread count |
| Service Mesh | Mesh-specific: mTLS rate, sidecar overhead, control plane CPU |

### Alert Rules (Prometheus)

| Alert | Condition | Duration | Severity |
|-------|-----------|----------|---------|
| ServiceDown | `up == 0` | 1m | `critical` |
| HighErrorRate | error rate > 5% | 5m | `warning` |
| HighLatency | p95 > 500ms | 5m | `warning` |
| PodRestartLoop | restarts > 3 in 15m | 0m | `critical` |

### Loki (Log Aggregation)

| Parameter | Value |
|-----------|-------|
| Namespace | `monitoring` |
| Port | 3100 |
| Storage | PersistentVolume (EBS, 10Gi) |
| Log Labels | `namespace`, `pod`, `container`, `service_mesh` |

### Zipkin (Tracing)

| Parameter | Value |
|-----------|-------|
| Namespace | `tracing` |
| Port | 9411 |
| Image | `openzipkin/zipkin` |

---

## IRSA Roles

Per cluster. Role names include the cluster/mesh name.

| Role Name Pattern | K8s ServiceAccount | Namespace | IAM Policy | Used By |
|-------------------|--------------------|-----------|------------|---------|
| `petclinic-{mesh}-eso-role` | `external-secrets-sa` | `external-secrets` | `secretsmanager:GetSecretValue`, `secretsmanager:DescribeSecret` on `arn:aws:secretsmanager:eu-central-1:{account}:secret:petclinic/*` | ESO |
| `petclinic-{mesh}-lb-controller-role` | `aws-load-balancer-controller` | `kube-system` | AWS LBC managed policy | ALB Controller |
| `petclinic-{mesh}-ebs-csi-role` | `ebs-csi-controller-sa` | `kube-system` | `AmazonEBSCSIDriverPolicy` | EBS CSI Driver |
| `petclinic-{mesh}-karpenter-role` | `karpenter` | `kube-system` | Karpenter controller policy | Karpenter |

### IRSA Trust Policy Template

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::{account}:oidc-provider/{oidc-provider}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "{oidc-provider}:sub": "system:serviceaccount:{namespace}:{sa-name}",
        "{oidc-provider}:aud": "sts.amazonaws.com"
      }
    }
  }]
}
```

---

## Security Controls

### Encryption Matrix

| Resource | Encryption at Rest | Key |
|----------|-------------------|-----|
| RDS MySQL | KMS (AWS default) | AWS managed |
| S3 (state bucket) | SSE-S3 (AES256) | AWS managed |
| EBS Volumes | Default encryption | AWS managed |
| ECR Images | AES256 | AWS managed |
| Secrets Manager | KMS (`aws/secretsmanager`) | AWS managed |
| ALB | TLS termination (ACM cert) | ACM |

### Pod Security Admission

| Namespace | Enforce | Warn |
|-----------|---------|------|
| `petclinic-linkerd` | `baseline` | `restricted` |
| `petclinic-istio` | `baseline` | `restricted` |
| `petclinic-cilium` | `baseline` | `restricted` |

---

## Scaling and Cost

### Monthly Cost Estimate

| Resource | Per Cluster | × 3 Clusters | Notes |
|----------|-------------|-------------|-------|
| EKS Control Plane | $73 | **$219** | Unavoidable |
| EC2 Nodes (2× t4g.small) | $0 | $0 | Graviton free trial until Dec 2026 |
| EBS (PVs) | $2 | $6 | 30 GB gp2 free tier (12 mo) |
| **Sub-total (per cluster)** | **~$75** | **~$225** | |

| Resource | Shared | Notes |
|----------|--------|-------|
| RDS MySQL (db.t4g.micro) | $0 | RDS free tier (750 hrs/mo, 12 mo) |
| S3 + state | $1 | |
| ECR Storage | $1 | |
| Route 53 | $2 | 3 records |
| Secrets Manager | $1 | |
| **Shared sub-total** | **~$5** | |

**Total: ~$230/month** (vs ~$80 for single cluster). EKS control plane × 3 is the primary cost.

> **Recommendation:** `terraform destroy` unused clusters after testing sessions. At $0.10/hr per control plane, running all 3 for 10 hrs/week = ~$130/month. Run one cluster at a time when not actively comparing.

### Spot Instance Configuration (Optional, after Graviton free trial)

| Parameter | Value |
|-----------|-------|
| Instance Types | `t4g.small`, `t4g.medium` |
| Capacity Type | `SPOT` with on-demand fallback |
| Savings | ~60-70% on compute |

---

## Docker Build

### Build Command

```bash
# Build all 8 Docker images for ARM64 (required for t4g Graviton nodes)
./mvnw clean install -P buildDocker -Dcontainer.platform="linux/arm64"
```

### Dockerfile Details

| Parameter | Value |
|-----------|-------|
| Base Image | `eclipse-temurin:17` |
| Build Strategy | Multi-stage (builder + runtime) |
| Target Platform | `linux/arm64` |
| Default Profile | `SPRING_PROFILES_ACTIVE=docker` |
| Memory Limit | 512M |
| Local Image Prefix | `springcommunity/` |

---

## Terraform Modules

### Module: `vpc`

**Path:** `terraform/modules/vpc/`

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `name` | string | VPC name | — |
| `vpc_cidr` | string | VPC CIDR block | — |
| `azs` | list(string) | AZs for subnets | — |
| `public_subnet_cidrs` | list(string) | Public subnet CIDRs | — |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `vpc_id` | string | VPC ID |
| `public_subnet_ids` | list(string) | Public subnet IDs |
| `rds_sg_id` | string | RDS security group ID |
| `alb_sg_id` | string | ALB security group ID |

### Module: `eks`

**Path:** `terraform/modules/eks/`

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `cluster_name` | string | EKS cluster name | — |
| `cluster_version` | string | Kubernetes version | `"1.31"` |
| `subnet_ids` | list(string) | Subnet IDs | — |
| `node_instance_types` | list(string) | EC2 instance types | `["t4g.small"]` |
| `node_ami_type` | string | AMI type | `"AL2_ARM_64"` |
| `node_min_size` | number | Min nodes | `2` |
| `node_max_size` | number | Max nodes | `4` |
| `node_desired_size` | number | Desired nodes | `2` |
| `node_disk_size` | number | Disk size (GB) | `20` |
| `addon_versions` | map(string) | Add-on version overrides | `{}` |
| `tags` | map(string) | Additional tags (incl. ServiceMesh) | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `cluster_name` | string | EKS cluster name |
| `cluster_endpoint` | string | API server endpoint |
| `cluster_ca_certificate` | string | CA cert (base64) |
| `oidc_provider_arn` | string | OIDC provider ARN |
| `oidc_provider_url` | string | OIDC provider URL |
| `node_group_name` | string | Managed node group name |
| `node_role_arn` | string | Node IAM role ARN |
| `cluster_sg_id` | string | EKS cluster security group ID |
| `node_sg_id` | string | EKS node security group ID |

### Module: `ecr`

**Path:** `terraform/modules/ecr/`

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `service_names` | list(string) | Service names for repos | — |
| `image_tag_mutability` | string | MUTABLE or IMMUTABLE | `"MUTABLE"` |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `repository_urls` | map(string) | service_name → ECR URL |
| `repository_arns` | map(string) | service_name → ECR ARN |

### Module: `rds`

**Path:** `terraform/modules/rds/`

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `project` | string | Project name | `"petclinic"` |
| `name` | string | DB identifier suffix | — |
| `subnet_ids` | list(string) | Subnet IDs | — |
| `security_group_id` | string | RDS security group ID | — |
| `instance_class` | string | RDS instance class | `"db.t4g.micro"` |
| `allocated_storage` | number | Storage (GB) | `20` |
| `multi_az` | bool | Multi-AZ | `false` |
| `backup_retention_period` | number | Backup days | `7` |
| `skip_final_snapshot` | bool | Skip snapshot on delete | `true` |
| `deletion_protection` | bool | Deletion protection | `false` |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `endpoint` | string | RDS endpoint hostname |
| `port` | number | RDS port (3306) |
| `db_instance_id` | string | RDS instance ID |
| `secret_arn` | string | Secrets Manager ARN for credentials |

### Module: `dns`

**Path:** `terraform/modules/dns/`

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `domain_name` | string | Domain for hosted zone | — |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `zone_id` | string | Route 53 hosted zone ID |
| `name_servers` | list(string) | NS records |
| `certificate_arn` | string | ACM wildcard certificate ARN |

### Module: `secrets`

**Path:** `terraform/modules/secrets/`

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `project` | string | Project name | `"petclinic"` |
| `openai_api_key` | string | OpenAI API key (sensitive) | — |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `openai_secret_arn` | string | Secrets Manager ARN for OpenAI key |

### Module: `observability`

**Path:** `terraform/modules/observability/`

Provisions the IAM roles and EBS storage prerequisites for the observability stack (Prometheus, Grafana, Loki). The actual Kubernetes workloads are deployed via Helm after cluster creation.

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `cluster_name` | string | EKS cluster name | — |
| `oidc_provider_arn` | string | OIDC provider ARN (for IRSA) | — |
| `oidc_provider_url` | string | OIDC provider URL | — |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `prometheus_irsa_role_arn` | string | IRSA role ARN for Prometheus |
| `grafana_irsa_role_arn` | string | IRSA role ARN for Grafana |

### Module: `karpenter`

**Path:** `terraform/modules/karpenter/`

Provisions IAM roles, SQS queue, and EventBridge rules for Karpenter.

| Input Variable | Type | Description | Default |
|---------------|------|-------------|---------|
| `cluster_name` | string | EKS cluster name | — |
| `oidc_provider_arn` | string | OIDC provider ARN | — |
| `node_role_arn` | string | Node IAM role ARN | — |
| `tags` | map(string) | Additional tags | `{}` |

| Output | Type | Description |
|--------|------|-------------|
| `karpenter_role_arn` | string | Karpenter controller IRSA role ARN |
| `karpenter_queue_name` | string | SQS interruption queue name |
| `karpenter_instance_profile_name` | string | Instance profile for Karpenter nodes |

---

## Helm Charts

### Architecture

Single generic Helm chart (`helm/petclinic-service/`) shared by all 8 services. Per-service and per-mesh configuration in `helm-values/`. ArgoCD merges values when deploying.

### Chart Structure

```
helm/
└── petclinic-service/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── configmap.yaml
        ├── serviceaccount.yaml
        ├── hpa.yaml
        ├── pdb.yaml
        └── _helpers.tpl
```

### values.yaml Defaults

```yaml
replicaCount: 1
image:
  repository: ""
  tag: "latest"
  pullPolicy: IfNotPresent
service:
  port: 8080
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
probes:
  readiness:
    path: /actuator/health/readiness
    initialDelaySeconds: 30
    periodSeconds: 10
  liveness:
    path: /actuator/health/liveness
    initialDelaySeconds: 60
    periodSeconds: 15
env: []
initContainers: []
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 4
  targetCPUUtilizationPercentage: 70
podDisruptionBudget:
  enabled: false
  minAvailable: 1
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
```

### Per-Service Values (`helm-values/`)

```
helm-values/
├── config-server.yaml
├── discovery-server.yaml
├── api-gateway.yaml
├── customers-service.yaml
├── visits-service.yaml
├── vets-service.yaml
├── genai-service.yaml
├── admin-server.yaml
├── linkerd.yaml      # Linkerd cluster overrides (mesh annotations, replicas)
├── istio.yaml        # Istio cluster overrides
└── cilium.yaml       # Cilium cluster overrides
```

---

## GitOps with ArgoCD

### Architecture

ArgoCD watches Git. GitHub Actions is CI-only. Each cluster has its own ArgoCD instance.

| Environment | Auto-Sync | Prune | Self-Heal | Manual Approval |
|-------------|-----------|-------|-----------|-----------------|
| linkerd | Yes | Yes | Yes | No |
| istio | Yes | Yes | Yes | No |
| cilium | Yes | Yes | Yes | No |

### Application CRDs

24 Applications total: 8 services × 3 clusters.

```
k8s/argocd/applications/
├── linkerd/     # 8 Application CRDs
├── istio/       # 8 Application CRDs
└── cilium/      # 8 Application CRDs
```

### Application CRD Template

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "{service}-{mesh}"
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/{your-username}/petclinic-platform.git
    targetRevision: main
    path: helm/petclinic-service
    helm:
      valueFiles:
        - ../../helm-values/{service}.yaml
        - ../../helm-values/{mesh}.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: "petclinic-{mesh}"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## Karpenter (Node Autoscaling)

### Prerequisites (Terraform — per cluster)

| Resource | Purpose |
|----------|---------|
| Karpenter Controller IRSA Role | EC2 management permissions |
| SQS Queue | Spot interruption notices |
| EventBridge Rules | Routes Spot/rebalance/health events to SQS |
| Instance Profile | Attached to Karpenter-launched nodes |

### NodePool

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["arm64"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["t4g.small", "t4g.medium"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
  limits:
    cpu: "8"
    memory: "16Gi"
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s
```

### EC2NodeClass

```yaml
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiSelectorTerms:
    - alias: al2023@latest
  subnetSelectorTerms:
    - tags:
        kubernetes.io/cluster/{cluster_name}: "shared"
  securityGroupSelectorTerms:
    - tags:
        Name: "{cluster_name}-node-sg"
  instanceProfile: "{cluster_name}-karpenter-node-profile"
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 20Gi
        volumeType: gp3
```

---

## ADR Index

| ADR | Title | Status | Summary |
|-----|-------|--------|---------|
| ADR-0001 | All-public subnet design | Accepted | No NAT Gateway, SGs as perimeter, saves ~$35-65/mo |
| ADR-0002 | EKS over ECS | Accepted | Industry relevance, Kubernetes learning |
| ADR-0003 | Shared RDS for all clusters | Accepted | Single `petclinic` DB shared by all 3 clusters for fair app-level comparison |
| ADR-0004 | Three independent EKS clusters | Accepted | One cluster per service mesh for isolated performance comparison |
| ADR-0005 | GitHub Actions with OIDC federation | Accepted | No long-lived AWS credentials |
| ADR-0006 | Single-AZ RDS | Accepted | Cost optimization for learning; multi-AZ doubles RDS cost |
| ADR-0007 | Helm over plain K8s YAML | Accepted | Generic chart shared across 8 services; ArgoCD GitOps |
| ADR-0008 | ArgoCD for GitOps (CD) | Accepted | CI pushes images, ArgoCD syncs all 3 clusters |
| ADR-0009 | Karpenter over Cluster Autoscaler | Accepted | Faster node provisioning, better Spot diversification |
| ADR-0010 | ECR shared across clusters | Accepted | Same images deployed to all 3 clusters for fair comparison |
| ADR-0011 | Secrets Manager for secrets | Accepted | Industry-standard, built-in rotation, fine-grained IAM |
| ADR-0012 | S3 native locking (no DynamoDB) | Accepted | Terraform ≥ 1.10.0 `use_lockfile = true` eliminates DynamoDB dependency; simpler bootstrap |
