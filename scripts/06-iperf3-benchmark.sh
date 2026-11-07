#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
kubectl apply -f manifests/iperf3/
kubectl rollout status deployment/iperf3-server-deployment --timeout=180s
kubectl rollout status daemonset/iperf3-clients --timeout=180s
echo '>>> Pod placement'; kubectl get pods -o wide -l 'app in (iperf3-server,iperf3-client)'
mapfile -t pods < <(kubectl get pods -l app=iperf3-client -o jsonpath='{range .items[*]}{.metadata.name}{"
"}{end}')
for pod in "${pods[@]}"; do
  [[ -n "$pod" ]] || continue
  echo; echo ">>> Benchmark from $pod (10 s)"
  kubectl exec "$pod" -- iperf3 -c iperf3-server -t 10
 done
