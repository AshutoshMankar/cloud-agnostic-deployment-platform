#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-evidence/local-$(date -u +%Y%m%dT%H%M%SZ).log}"
mkdir -p "$(dirname "$OUT")"
{
  echo "UTC timestamp: $(date -u +%FT%TZ)"
  echo '--- kubectl context ---'; kubectl config current-context
  echo '--- nodes ---'; kubectl get nodes -o wide
  echo '--- namespace resources ---'; kubectl get all,pdb -n platform-poc -o wide
  echo '--- API rollout ---'; kubectl rollout status deployment/api -n platform-poc --timeout=120s
  echo '--- events ---'; kubectl get events -n platform-poc --sort-by=.lastTimestamp
} 2>&1 | tee "$OUT"
echo "Evidence written to $OUT"
