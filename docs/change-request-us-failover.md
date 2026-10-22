# Change Request: Second Dedicated Stack - US-West with US-East Failover

**Status:** Proposed design only; not implemented or tested.
**Scope:** One additional dedicated US tenant stack, deployed from the existing versioned Terraform and Kubernetes templates.

## 1. Proposed change
Provision a dedicated stack in **US-West** as the primary region and a recovery stack in **US-East**. Each region must have isolated networking, secrets/KMS keys, application workloads, database, Redis, telemetry, and backups. Use the same reviewed application artifact digest and configuration template in both regions, with region-specific settings.

## 2. Failover policy and proposed targets
- **Trigger:** Initiate failover when the primary region is confirmed unavailable, or critical health checks fail continuously for 5 minutes and the incident responder confirms regional impact. Avoid automatic failover based on a single failed probe.
- **Proposed RTO:** Restore service in US-East within 30 minutes.
- **Proposed RPO:** No more than 5 minutes of database data loss, subject to the selected replication mode and measured replication lag.
- **Traffic routing:** Use health-checked regional routing. Promote US-East only after database readiness, application readiness, and queue-recovery checks pass.
- **Split-brain prevention:** Fence or otherwise prevent writes to the old primary before enabling writes in the recovery region.

These are proposed acceptance targets, not measured results. Confirm that the selected database and routing services can meet them before approval.

## 3. Data and queue recovery
Select and test a database replication or backup/restore strategy. Document replication lag, consistency constraints, recovery procedures, and failback steps. Define whether queued jobs are replicated, replayed, or reconstructed. Ensure job processing is idempotent and that queue durability is explicitly configured; do not assume Redis replication guarantees zero job loss.

## 4. Validation and rollout
Before production approval, test regional failure, database promotion, worker recovery, traffic switching, duplicate-job handling, and failback. Record actual RTO/RPO, data consistency, and error rates. Roll out to the dedicated US tenant only after the change is reviewed and acceptance criteria pass.

## 5. Residency and rollback
This change applies only to the US tenant. EU tenant data, databases, backups, logs, and telemetry must remain in EU regions and must not be replicated to US-West or US-East. If validation fails, keep or restore traffic to the known-good region only after verifying database write ownership and consistency.

**Approval required:** Architecture, security/data residency, database operations, and service owner sign-off before implementation.
