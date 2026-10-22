# Decisions and risks (draft)

## Decisions
1. **Terraform for infrastructure.** Rejected provider-specific hand-written scripts as the primary interface because they create configuration drift; provider modules remain cloud-specific.
2. **Kubernetes for workload portability.** Rejected separate deployment systems per cloud; acknowledge managed control-plane and networking differences.
3. **GitOps pull model for production.** Rejected direct long-lived CI credentials to production clusters; CI proposes a digest update and GitOps reconciles it.
4. **API canary for production.** Rejected all-at-once replacement because it increases blast radius. Local PoC does not yet implement weighted routing.
5. **Worker graceful drain and idempotency.** Rejected forced termination because jobs may run for up to 60 seconds and retries can duplicate side effects.
6. **Expand/contract database changes.** Rejected relying on application rollback after destructive migrations; schema compatibility must span release boundaries.
7. **Shared plus dedicated templates.** Rejected maintaining separate hand-built stacks; use one versioned template with reviewed tenant configuration and policy enforcement.

## Top five risks
1. PostgreSQL connection exhaustion or query saturation during a 15x API surge.
2. Non-backward-compatible migrations break rollback or mixed-version deployments.
3. Queue backlog grows faster than workers can drain it; retries cause duplicate side effects.
4. Misconfigured tenant placement, backups, logs, or telemetry violate EU residency or tenant isolation.
5. Provider-specific networking, IAM, database, and load-balancer differences undermine claimed portability.

Mitigations include connection pooling and explicit DB budgets, expand/contract migrations, idempotent job handlers, policy-as-code and regional data controls, plus per-provider integration tests.
