#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://127.0.0.1:8080}"
for path in /healthz /readyz /metrics; do
  code="$(curl --silent --show-error --output /tmp/poc-response.txt --write-out '%{http_code}' --max-time 5 "${BASE_URL}${path}")"
  if [[ "$code" != "200" ]]; then echo "FAIL ${path}: HTTP ${code}" >&2; cat /tmp/poc-response.txt >&2; exit 1; fi
  echo "PASS ${path}: HTTP ${code}"
done
