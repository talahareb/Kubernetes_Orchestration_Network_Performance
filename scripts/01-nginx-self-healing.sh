#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
kubectl apply -f manifests/nginx/
kubectl rollout status deployment/nginx --timeout=180s
printf '
Services:
'; kubectl get svc nginx-clusterip nginx-port
printf '
Before deleting a pod:
'; kubectl get pods -l app=nginx-lab
pod=$(kubectl get pod -l app=nginx-lab -o jsonpath='{.items[0].metadata.name}')
[[ -n "$pod" ]] || { echo 'No NGINX pod found' >&2; exit 1; }
echo "Deleting $pod to demonstrate automatic reconciliation..."
kubectl delete pod "$pod"
kubectl rollout status deployment/nginx --timeout=180s
printf '
After recovery:
'; kubectl get pods -l app=nginx-lab
printf '
In a second terminal, run: kubectl get deployment nginx --watch
'
