# Architecture (draft — design, not deployed production architecture)

## Goal
Provide a cloud-agnostic deployment pattern for a stateless API, queue-consuming worker, PostgreSQL, and Redis. Support a shared environment and isolated dedicated tenant stacks while preserving EU tenant data residency.

## Proposed layers
1. **Provider layer:** Terraform provider modules for VPC/networking, managed Kubernetes, managed PostgreSQL, managed Redis, KMS/secrets integrations, object storage, and load balancing. Separate state and credentials per environment/region.
2. **Platform layer:** Kubernetes namespaces, policy, ingress, workload identity, observability, autoscaling, GitOps controller, and shared operational tooling.
3. **Application layer:** API/worker Deployments, Services, probes, resource requests/limits, PDBs, HPA/KEDA policies, and tenant overlays. Application image is supplied externally and pinned by digest.

## Release flow
Commit -> build once -> vulnerability scan + SBOM -> sign image -> publish digest -> deploy dev -> metric gates -> staging -> metric gates -> shared production canary -> dedicated tenant rings -> additional regions. GitOps pull is preferred for deployment reconciliation; CI updates a reviewed release manifest containing the immutable digest.

## Deployment design
- API: canary behind a traffic manager that supports weighted routing. Example steps 5%, 25%, 50%, 100%, with at least 10 minutes and a minimum request sample per step. Abort on elevated 5xx, p95 >= 400 ms, readiness failures, or SLO burn-rate alerts. The local PoC currently demonstrates only a rolling Deployment and manual rollback mechanics, not weighted canary.
- Worker: controlled rolling replacement with graceful termination and queue drain. Stop claiming new work, finish in-flight jobs within the 60-second job limit, then terminate. Ensure jobs are idempotent and visibility timeout exceeds processing plus shutdown margin. Never scale to zero if that violates latency objectives.
- Database: expand/contract migrations. Deploy additive schema first, deploy code compatible with old and new schema, backfill, verify, then contract in a later release. A destructive migration is not safely reversible merely by rolling back the application; restore or forward-fix may be required.

## Local target
kind is the local validation target. It validates Kubernetes resource shape and basic rollout behavior, not cloud networking, managed database behavior, autoscaling capacity, EU residency, or cloud failover.

## Portability limits
Terraform syntax and Kubernetes APIs are portable; managed database semantics, IAM/workload identity, KMS, load balancer annotations, DNS, private networking, storage classes, regional availability, quota, autoscaler integration, and pricing are provider-specific. These require adapters and conformance testing.

## Residency and failover
EU tenants must be pinned to EU regions, with EU-only storage, backups, logs, metrics labels, and encryption key location. Enforce region policy in CI and cloud policy. US-West/US-East failover is a separate tenant configuration and must not replicate EU tenant data to the US.
