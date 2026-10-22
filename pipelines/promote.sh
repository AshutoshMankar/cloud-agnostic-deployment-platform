#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 2 ]]; then echo "Usage: $0 <environment> <image@sha256:digest>" >&2; exit 2; fi
ENVIRONMENT="$1"; IMAGE_DIGEST="$2"
if [[ ! "$IMAGE_DIGEST" =~ @sha256:[a-f0-9]{64}$ ]]; then echo 'ERROR: image must be pinned by sha256 digest' >&2; exit 2; fi
case "$ENVIRONMENT" in dev|staging|production) ;; *) echo 'ERROR: environment must be dev, staging, or production' >&2; exit 2;; esac
echo "Validated promotion request: environment=${ENVIRONMENT}, artifact=${IMAGE_DIGEST}"
echo 'No deployment performed: environment overlays and GitOps controller are not configured.'
