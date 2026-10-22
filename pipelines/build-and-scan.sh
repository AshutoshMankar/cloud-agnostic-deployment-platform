#!/usr/bin/env bash
set -euo pipefail
echo 'Starter only: no application source, Dockerfile, or registry configured.' >&2
echo 'Configure image build, Trivy scan, SBOM, signing (e.g. cosign), and publish immutable digest before enabling promotion.' >&2
exit 2
