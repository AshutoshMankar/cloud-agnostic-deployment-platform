#!/usr/bin/env bash
set -euo pipefail
kubectl apply -k platform/overlays/local
kubectl rollout status deployment/api -n platform-poc --timeout=120s
kubectl rollout status deployment/worker-placeholder -n platform-poc --timeout=120s
kubectl get pods,svc,pdb -n platform-poc -o wide
