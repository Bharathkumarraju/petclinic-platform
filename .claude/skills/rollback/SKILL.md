---
name: rollback
description: Roll back a failed deployment to the previous revision in a mesh cluster
disable-model-invocation: true
argument-hint: "[service] [mesh]"
---

# /rollback [service] [mesh]

Roll back a failed deployment to its previous working revision.

## Arguments

- `service` — Service to roll back (e.g., `api-gateway`, `customers-service`) or `all`
- `mesh` — Target cluster: `linkerd`, `istio`, or `cilium` (default: `linkerd`)

## Steps

1. Set the namespace:
   - `linkerd` → `petclinic-linkerd`
   - `istio`   → `petclinic-istio`
   - `cilium`  → `petclinic-cilium`

2. Show current rollout status and history:
   ```bash
   kubectl rollout status deployment/{service} -n petclinic-{mesh}
   kubectl rollout history deployment/{service} -n petclinic-{mesh}
   ```

3. Show what changed in the current revision vs previous:
   ```bash
   kubectl rollout history deployment/{service} -n petclinic-{mesh} --revision={current}
   kubectl rollout history deployment/{service} -n petclinic-{mesh} --revision={previous}
   ```

4. Execute the rollback:
   ```bash
   kubectl rollout undo deployment/{service} -n petclinic-{mesh}
   ```

5. Monitor rollout:
   ```bash
   kubectl rollout status deployment/{service} -n petclinic-{mesh} --timeout=120s
   ```

6. Verify the rollback:
   ```bash
   kubectl get pods -l app.kubernetes.io/name={service} -n petclinic-{mesh}
   ```

7. If rolling back `all`:
   - Roll back in reverse order (application services first, then discovery-server, then config-server)
   - Verify each service before proceeding to the next
   - If any rollback fails, stop and report

8. Show summary:
   ```
   ## Rollback: {service} ({mesh})

   Previous revision: {N} (image: {old-image})
   Rolled back to: {N-1} (image: {previous-image})
   Status: {success/failed}
   Pod status: {Running/etc}
   ```

## Important

- When rolling back `all`, go in reverse deployment order
- If rollback fails, do NOT retry — investigate first
- Suggest running `/smoke-test {mesh}` after rollback to verify health
- If the issue affects all three clusters, check the shared image tag in `helm-values/{service}.yaml`
