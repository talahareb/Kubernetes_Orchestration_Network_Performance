#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
kubectl apply -f manifests/resources/01-cpu-stress-baseline.yaml
kubectl rollout status deployment/cpu-stress --timeout=120s
echo 'Baseline: run kubectl top pods (requires metrics-server); press Enter to apply 300m CPU limit.'
read -r _
kubectl apply -f manifests/resources/02-cpu-stress-limited.yaml
kubectl rollout status deployment/cpu-stress --timeout=120s
echo 'Limited: run kubectl top pods and inspect the changed CPU usage.'
