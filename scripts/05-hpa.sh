#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
kubectl apply -f manifests/hpa/
kubectl rollout status deployment/php-apache --timeout=180s
kubectl get hpa php-apache
printf '
In another terminal: kubectl get hpa php-apache --watch
'
printf 'Generate load in the foreground using:
'
printf "kubectl run load-generator --rm -it --restart=Never --image=busybox:1.36 -- /bin/sh -c 'while true; do wget -q -O- http://php-apache >/dev/null; done'
"
printf 'Stop the load generator to observe scale-down, which may take several minutes.
'
