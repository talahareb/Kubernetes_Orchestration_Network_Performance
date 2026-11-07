#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
echo '>>> Connected cluster'; kubectl cluster-info
echo '>>> Nodes and node names'; kubectl get nodes -o wide
echo '>>> HPA metrics API (optional for other experiments)'
if ! kubectl top nodes; then
  echo 'Node metrics unavailable; HPA / kubectl top require metrics-server.' >&2
fi
