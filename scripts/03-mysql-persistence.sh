#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
[[ "$(kubectl get secret mysql-credentials -o name 2>/dev/null || true)" ]] || {
  echo 'Run scripts/02-mysql-secret.sh first.' >&2; exit 1;
}
echo 'Prerequisite: /data must exist and be writable by MySQL on node worker-2.'
kubectl apply -f manifests/mysql/01-local-pv.yaml
kubectl apply -f manifests/mysql/02-mysql-pvc.yaml
kubectl apply -f manifests/mysql/03-mysql-deployment.yaml
kubectl rollout status deployment/mysql --timeout=360s
kubectl exec deploy/mysql -- sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "CREATE DATABASE IF NOT EXISTS trains; SHOW DATABASES;"'
oldpod=$(kubectl get pod -l app=mysql-lab -o jsonpath='{.items[0].metadata.name}')
[[ -n "$oldpod" ]] || { echo 'Cannot find MySQL pod to replace' >&2; exit 1; }
kubectl delete pod "$oldpod"
kubectl wait --for=delete "pod/$oldpod" --timeout=180s
kubectl rollout status deployment/mysql --timeout=360s
kubectl exec deploy/mysql -- sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot -e "SHOW DATABASES;"'
echo 'Verify the trains database remains after replacement. Local PV storage persists.'
