---
name: deploy
description: Deploy services to a mesh cluster via ArgoCD (linkerd, istio, or cilium)
disable-model-invocation: true
argument-hint: "[mesh] [service|all]"
---

# /deploy [mesh] [service|all]

Deploy services to a service mesh cluster via ArgoCD.

## Arguments

- `mesh` — Target cluster: `linkerd`, `istio`, or `cilium` (required)
- `service` — Specific service to deploy (e.g., `config-server`, `api-gateway`) or `all`
- Default service: `all`

## Steps

1. Validate the mesh argument — must be one of: `linkerd`, `istio`, `cilium`.
   Set the namespace: `petclinic-{mesh}` (e.g., `petclinic-linkerd`)

2. Verify kubectl context is configured for the target cluster:
   ```bash
   kubectl config current-context
   ```
   If not configured, run:
   ```bash
   aws eks update-kubeconfig --name petclinic-{mesh} --region eu-central-1
   ```

3. Check if ArgoCD is installed:
   ```bash
   kubectl get namespace argocd 2>/dev/null
   ```

4. **If ArgoCD is installed (standard path):**

   - **all**: Sync all ArgoCD Applications for this mesh:
     ```bash
     argocd app sync -l environment={mesh}
     ```
   - **specific service**: Sync that service's ArgoCD Application:
     ```bash
     argocd app sync {service}-{mesh}
     ```
   - Wait for sync to complete:
     ```bash
     argocd app wait {service}-{mesh} --timeout 120
     ```

5. **If ArgoCD is NOT installed (bootstrap path):**

   - Apply namespace first (idempotent):
     ```bash
     kubectl apply -f k8s/base/namespaces.yaml
     ```
   - **all**: Install via Helm directly (startup order: config → discovery → rest):
     ```bash
     for service in config-server discovery-server api-gateway customers-service visits-service vets-service genai-service admin-server; do
       helm upgrade --install $service helm/petclinic-service/ \
         -f helm-values/$service.yaml \
         -f helm-values/{mesh}.yaml \
         -n petclinic-{mesh} --create-namespace
     done
     ```
   - **specific service**:
     ```bash
     helm upgrade --install {service} helm/petclinic-service/ \
       -f helm-values/{service}.yaml \
       -f helm-values/{mesh}.yaml \
       -n petclinic-{mesh}
     ```

6. Service startup order (when deploying all):
   - Deploy config-server first, wait for ready
   - Deploy discovery-server second, wait for ready
   - Deploy all remaining services

7. Monitor rollout status:
   ```bash
   kubectl rollout status deployment/{service} -n petclinic-{mesh} --timeout=120s
   ```

8. Show final pod status:
   ```bash
   kubectl get pods -n petclinic-{mesh} -o wide
   ```

9. If any pod fails to start, show logs:
   ```bash
   kubectl logs deployment/{failing-service} -n petclinic-{mesh} --tail=50
   ```

## Important

- All 3 cluster environments use ArgoCD auto-sync (this is a comparison platform, not production)
- Helm values: per-service (`helm-values/{service}.yaml`) merged with per-mesh (`helm-values/{mesh}.yaml`)
- ArgoCD Application CRDs live in `k8s/argocd/applications/{mesh}/`
- Monitor the rollout — don't assume success without checking pod status
- To compare mesh behavior, run against all three clusters and compare results
