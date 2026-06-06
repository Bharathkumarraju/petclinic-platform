---
name: logs
description: View and troubleshoot service logs and pod status in a mesh cluster
disable-model-invocation: true
argument-hint: "[service] [mesh]"
---

# /logs [service] [mesh]

View logs and debug information for a service in the specified mesh cluster.

## Arguments

- `service` — Service name (e.g., `config-server`, `api-gateway`, `customers-service`)
- `mesh` — Target cluster: `linkerd`, `istio`, or `cilium` (default: `linkerd`)

## Steps

1. Set the namespace based on mesh:
   - `linkerd` → `petclinic-linkerd`
   - `istio`   → `petclinic-istio`
   - `cilium`  → `petclinic-cilium`

2. Show pod status for the service:
   ```bash
   kubectl get pods -l app.kubernetes.io/name={service} -n petclinic-{mesh} -o wide
   ```

3. Show recent events for the pod:
   ```bash
   kubectl describe pod -l app.kubernetes.io/name={service} -n petclinic-{mesh} | tail -30
   ```

4. Show logs (last 100 lines):
   ```bash
   kubectl logs -l app.kubernetes.io/name={service} -n petclinic-{mesh} --tail=100
   ```

5. If the pod is in CrashLoopBackOff, show previous container logs:
   ```bash
   kubectl logs -l app.kubernetes.io/name={service} -n petclinic-{mesh} --previous --tail=50
   ```

6. Show resource usage if metrics-server is available:
   ```bash
   kubectl top pod -l app.kubernetes.io/name={service} -n petclinic-{mesh} 2>/dev/null || echo "Metrics server not available"
   ```

7. Present a summary:
   ```
   ## Logs: {service} ({mesh})

   Pod Status: {Running/CrashLoopBackOff/Pending/etc.}
   Restarts: {count}
   Uptime: {age}

   ### Recent Events
   {key events}

   ### Log Highlights
   {errors/warnings from logs}

   ### Suggested Actions
   {troubleshooting suggestions based on findings}
   ```

## Important

- This is read-only — it does not restart or modify anything
- Always use --tail to limit log output
- If service name is omitted, show status of ALL pods in the namespace
- To compare behavior across meshes, run for all three: linkerd, istio, cilium
