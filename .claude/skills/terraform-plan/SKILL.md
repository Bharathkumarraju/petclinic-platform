---
name: terraform-plan
description: Run terraform init + plan for an environment and show summary
disable-model-invocation: true
argument-hint: "[env]"
---

# /terraform-plan [env]

Run Terraform init and plan for the specified environment.

## Arguments

- `env` — Target environment: `shared`, `linkerd`, `istio`, or `cilium`
- Default: `shared`

## Steps

1. Determine the environment directory:
   - `shared`  → `terraform/environments/shared/`
   - `linkerd` → `terraform/environments/linkerd/`
   - `istio`   → `terraform/environments/istio/`
   - `cilium`  → `terraform/environments/cilium/`

2. Run `terraform init` in the environment directory:
   ```bash
   cd terraform/environments/{env} && terraform init
   ```

3. Run `terraform plan` and save the plan:
   ```bash
   cd terraform/environments/{env} && terraform plan -out plan.out
   ```

4. Show a summary of the plan output:
   - Resources to add, change, destroy
   - Any warnings or errors
   - Highlight any resources being destroyed (these need careful review)

5. If the plan shows destroys, warn the user explicitly:
   ```
   WARNING: This plan will DESTROY {N} resource(s). Review carefully before applying.
   ```

## Deploy Order

When provisioning from scratch, always plan/apply in this order:
1. `shared` — VPC first; all clusters read VPC outputs via remote state
2. `linkerd`, `istio`, `cilium` — EKS cluster environments (can be done in parallel)

## Important

- Always use `-out plan.out` so the exact plan can be applied later
- Never run apply automatically — this skill only plans
- If init fails, show the error and suggest fixes (missing backend, provider issues)
- State backend uses S3 native locking (`use_lockfile = true`) — no DynamoDB table needed
- State bucket: `petclinic-terraform-state-bkr`, region: `eu-central-1`
