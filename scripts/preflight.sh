#!/usr/bin/env bash
set -euo pipefail
for cmd in git docker kind kubectl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then echo "ERROR: required command not found: $cmd" >&2; exit 1; fi
done
docker info >/dev/null
echo 'Preflight passed.'
kubectl version --client
kind get clusters
