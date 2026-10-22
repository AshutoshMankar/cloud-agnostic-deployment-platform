# Cloud-Agnostic Deployment Platform (PoC)

A local-first proof of concept for a cloud-agnostic deployment platform. This repository separates provider infrastructure, platform resources, and application deployment configuration.

## Status and honesty

- **Locally validated:** API Deployment with 4 replicas, Redis-backed worker, successful processing of a 1,000-job batch, a 5,000-job batch, and recovery of an unfinished queued job after worker restart.
- **Load-test evidence:** Fortio achieved approximately 150, 500, 1,000, and 2,248 QPS in separate tests. At 150 QPS during a rolling update, all 9,000 requests returned HTTP 200. These are local Kind-cluster results, not production capacity guarantees.
- **Queue status at final capture:** Redis `jobs` queue = 0; `jobs:processing` queue = 0. API = 4/4 replicas; Redis = 1/1; worker = 1/1.
- **Worker limitations:** The current worker is a proof-of-concept consumer, not a production-grade exactly-once processing system. Idempotency, concurrent-worker recovery, and durable production queue guarantees still require implementation and testing.

- **Implemented in this repository:** local Kubernetes manifests, a clearly labelled mock API fixture for validating probes and rollout mechanics, smoke-test and rollback scripts, and a GitHub Actions workflow for repository validation.
- **Not yet implemented / not verified:** provisioning any cloud account, production database or Redis, real application image deployment, artifact signing, real traffic-weighted canary, queue-depth autoscaling, 15x load test, production SLO validation, backup restore, EU residency validation, cross-cloud failover, and budget estimates based on live cloud prices.
- The mock API is only a platform test fixture. It is **not** a rewrite or substitute for the supplied black-box application.

## Prerequisites

- Docker Desktop or Docker Engine
- `kind`, `kubectl`, `kustomize` (or kubectl's built-in Kustomize), `git`
- Optional: `shellcheck`, `kubeconform`

## First local run

From the repository root:

```bash
kind get clusters
kind create cluster --name cap-platform # only if you do not already have a suitable cluster
kubectl cluster-info --context kind-cap-platform
kubectl apply -k platform/overlays/local
kubectl rollout status deployment/api -n platform-poc --timeout=120s
kubectl get pods,svc,pdb -n platform-poc
kubectl port-forward -n platform-poc svc/api 8080:8080
```

In another terminal:

```bash
./scripts/smoke-test.sh http://127.0.0.1:8080
```

The local overlay uses a mock API fixture so the platform can be exercised without the black-box image. Replace the mock container command/image with the real API image before claiming application-level evidence.

## Rollback exercise

```bash
./scripts/rollback-test.sh
```

This script deploys a deliberately invalid image tag to a separate test Deployment, waits for the rollout to fail, and rolls it back. It demonstrates Kubernetes rollout recovery, not automated production canary analysis. Inspect its output and save it under `evidence/` only after actually running it.

## GitHub Actions

The workflow validates YAML syntax and shell syntax on pushes and pull requests. It does not build or publish the black-box application because no source code or image reference has been supplied. Add registry authentication and image build/sign/promotion only after choosing the registry and confirming the application's build inputs.

## Repository layers

- `infra/terraform`: provider and environment-specific infrastructure (intended; not yet provisioned).
- `platform/base`: reusable Kubernetes resources.
- `platform/overlays`: environment and tenant-specific settings.
- `pipelines/`: image supply-chain and promotion scripts (starter placeholders).
- `docs/`: architecture, decisions, risks, cost, and change request.
