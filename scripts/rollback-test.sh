#!/usr/bin/env bash
# Demonstrates kubectl rollout recovery on a disposable test Deployment.
# It does not prove a production canary controller or SLO-based rollback.
set -euo pipefail
NS="platform-poc"
NAME="rollback-demo"
cleanup() { kubectl delete deployment "$NAME" -n "$NS" --ignore-not-found=true >/dev/null 2>&1 || true; }
trap cleanup EXIT
kubectl create deployment "$NAME" --image=nginx:1.27-alpine -n "$NS"
kubectl rollout status deployment/"$NAME" -n "$NS" --timeout=120s
kubectl set image deployment/"$NAME" nginx=nginx:this-tag-does-not-exist -n "$NS"
if kubectl rollout status deployment/"$NAME" -n "$NS" --timeout=35s; then
  echo 'ERROR: bad rollout unexpectedly succeeded' >&2; exit 1
else
  echo 'Expected failure observed; initiating rollback.'
fi
kubectl rollout undo deployment/"$NAME" -n "$NS"
kubectl rollout status deployment/"$NAME" -n "$NS" --timeout=120s
echo 'PASS: disposable Deployment recovered after a bad image rollout.'
