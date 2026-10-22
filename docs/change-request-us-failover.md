# Change request addendum: second dedicated stack in US-West with US-East failover

**Status:** design only; not implemented or tested.

Provision a second dedicated tenant stack using the same versioned Terraform and platform template. Primary region: US-West. Recovery region: US-East. Use region-local networking, secrets/KMS keys, databases, Redis, telemetry, and backups. Route health-checked traffic to US-East only when the failover criteria are met.

Database failover requires an explicit replication model (managed cross-region replication or tested backup/restore), measured RPO/RTO, and a runbook covering fencing the old primary to avoid split brain. Redis queue recovery must define whether jobs are replicated, replayed, or reconstructed; do not assume cache/queue durability without verifying configuration. Test failover and failback under controlled conditions before production approval.

This US failover applies only to the US tenant. EU tenant data, backups, logs, and telemetry must remain in EU regions and must not be replicated to either US region.
