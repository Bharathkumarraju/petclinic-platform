---
name: smoke-test
description: Run health checks against deployed services in a mesh cluster
disable-model-invocation: true
argument-hint: "[mesh]"
---

# /smoke-test [mesh]

Run smoke tests against deployed services to verify they are healthy.

## Arguments

- `mesh` — Target cluster: `linkerd`, `istio`, or `cilium` (default: `linkerd`)

## Steps

1. Set the namespace based on mesh:
   - `linkerd` → `petclinic-linkerd`
   - `istio`   → `petclinic-istio`
   - `cilium`  → `petclinic-cilium`

2. Check if `scripts/smoke-test.sh` exists. If so, run it:
   ```bash
   bash scripts/smoke-test.sh {mesh}
   ```

3. If the script doesn't exist, run manual health checks:

   a. Check all pods are running:
      ```bash
      kubectl get pods -n petclinic-{mesh} --no-headers | grep -v Running
      ```
      If any pods are not Running, report them.

   b. For each service, port-forward and check health endpoint:
      ```bash
      kubectl port-forward svc/{service} {local-port}:{service-port} -n petclinic-{mesh} &
      PF_PID=$!
      sleep 3
      curl -sf http://localhost:{local-port}/actuator/health || echo "FAIL: {service}"
      kill $PF_PID 2>/dev/null
      ```

   c. Service health check ports:
      | Service | Port | Health Endpoint |
      |---------|------|----------------|
      | config-server | 8888 | /actuator/health |
      | discovery-server | 8761 | /actuator/health |
      | api-gateway | 8080 | /actuator/health |
      | customers-service | 8081 | /actuator/health |
      | visits-service | 8082 | /actuator/health |
      | vets-service | 8083 | /actuator/health |
      | genai-service | 8084 | /actuator/health |
      | admin-server | 9090 | /actuator/health |

4. Present results:
   ```
   ## Smoke Test Results: {mesh}

   | Service | Pod Status | Health Check | Notes |
   |---------|-----------|-------------|-------|
   | config-server | Running | PASS | |
   | discovery-server | Running | PASS | |
   | ... | ... | ... | ... |

   Overall: {N}/8 services healthy
   ```

5. If any service fails, show:
   - Pod status and events
   - Recent logs (last 20 lines)
   - Suggested troubleshooting steps

## Important

- This is a read-only verification — it does not deploy or modify anything
- Port-forwarding is temporary and cleaned up after each check
- To compare mesh behavior, run against all three clusters: `/smoke-test linkerd`, `/smoke-test istio`, `/smoke-test cilium`
