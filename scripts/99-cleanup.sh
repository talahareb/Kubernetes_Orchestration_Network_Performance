#!/usr/bin/env bash
# Delete demo workloads only. Persistent volume and data are intentionally retained.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
kubectl delete -f manifests/iperf3/ --ignore-not-found
kubectl delete -f manifests/hpa/ --ignore-not-found
kubectl delete -f manifests/resources/02-cpu-stress-limited.yaml --ignore-not-found
kubectl delete -f manifests/nginx/ --ignore-not-found
kubectl delete -f manifests/mysql/03-mysql-deployment.yaml --ignore-not-found
printf '
MySQL PV, PVC, Secret, and data on worker-2 were intentionally NOT deleted.
'
printf 'Review persistent data and Retain policy before manual cleanup.
'
