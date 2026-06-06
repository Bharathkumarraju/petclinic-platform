---
paths:
  - "helm/**"
  - "helm-values/**/*.yaml"
  - "helm-values/**/*.yml"
---

# Helm Rules

## Chart Structure

Single generic chart shared by all 8 services:

```
helm/petclinic-service/
├── Chart.yaml              # Chart metadata (name, version, appVersion)
├── values.yaml             # Default values (overridden by per-service/env files)
└── templates/
    ├── _helpers.tpl         # Template helpers (labels, names, selectors)
    ├── deployment.yaml      # Deployment with probes, resources, init containers
    ├── service.yaml         # ClusterIP service
    ├── configmap.yaml       # ConfigMap (if needed)
    ├── hpa.yaml             # HPA (conditionally enabled)
    └── NOTES.txt            # Post-install notes
```

## Values Hierarchy

ArgoCD merges values files in this order (last wins):

1. `helm/petclinic-service/values.yaml` — chart defaults
2. `helm-values/{service}.yaml` — per-service config (ports, env vars, init containers)
3. `helm-values/{mesh}.yaml` — per-mesh overrides (mesh annotations, sidecar injection)

## Per-Service Values (`helm-values/{service}.yaml`)

Each service file MUST specify:
- `service.port` — the service port (8888, 8761, 8080, 8081, 8082, 8083, 8084, 9090)
- `image.name` — ECR image name only (e.g., `config-server`); registry is shared across all meshes
- `env` — extra static environment variables beyond `SPRING_PROFILES_ACTIVE`
- `secrets` — secret-backed env vars (list of `{name, secretName, key}`)
- `initContainers` — startup dependency wait containers (config-server, discovery-server)
- `springProfiles` — Spring profiles (e.g., `docker`, `docker,mysql`)

## Per-Mesh Values (`helm-values/{mesh}.yaml`)

- `linkerd.yaml` — Linkerd proxy injection annotations, namespace label
- `istio.yaml` — Istio ambient mode labels, waypoint configuration
- `cilium.yaml` — Cilium network policy annotations

**ECR registry** is shared — all three clusters pull from the same repos (no mesh/env prefix):
- `533267262133.dkr.ecr.eu-central-1.amazonaws.com/petclinic/{service-name}`

## Template Conventions

- Use Go template syntax: `{{ .Values.x }}`, `{{ include "helper" . }}`, `{{ tpl .Values.x . }}`
- Use `_helpers.tpl` for reusable labels, names, and selectors — do not duplicate label blocks
- Use `{{- if .Values.x.enabled }}` for conditional resources (HPA, PDB, ConfigMap)
- Use `{{- with }}` to scope into nested values
- Use `{{- toYaml . | nindent N }}` for rendering YAML blocks with correct indentation
- NEVER hardcode environment-specific values in templates — use values files
- NEVER put secrets in values files — use ExternalSecret CRs in `k8s/base/external-secrets/`

## Validation

Before committing any Helm changes, validate with:

```bash
# Render templates for a specific service + mesh
helm template petclinic helm/petclinic-service/ \
  -f helm-values/{service}.yaml \
  -f helm-values/{mesh}.yaml

# Lint the chart
helm lint helm/petclinic-service/ \
  -f helm-values/{service}.yaml \
  -f helm-values/{mesh}.yaml
```

## Image Tags

- Use commit SHA tags, never `latest`
- CI updates `image.tag` in `helm-values/{service}.yaml` — ArgoCD detects and syncs
- Template renders: `image: "{{ .Values.image.registry }}/{{ .Values.image.name }}:{{ .Values.image.tag }}"`
- `image.registry` comes from the shared ECR registry; `image.name` from the per-service file

## Validation Script

Run `scripts/validate-helm.sh` to lint, template, and dry-run all 24 releases (8 services × 3 meshes).
Supports `--mesh linkerd|istio|cilium` and `--service <name>` filters.

## Startup Order

Init containers enforce the dependency chain:
- **config-server**: no init containers
- **discovery-server**: wait for config-server:8888
- **all other services**: wait for config-server:8888 AND discovery-server:8761

Per-service values files define the init containers — the template renders them.
