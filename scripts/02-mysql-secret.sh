#!/usr/bin/env bash
# Creates a local cluster secret without committing plaintext credentials.
set -euo pipefail
if [[ -z "${MYSQL_ROOT_PASSWORD:-}" ]]; then
  if [[ ! -t 0 ]]; then echo 'Set MYSQL_ROOT_PASSWORD or run interactively.' >&2; exit 1; fi
  read -r -s -p 'Local lab MySQL root password: ' MYSQL_ROOT_PASSWORD
  echo
fi
[[ -n "${MYSQL_ROOT_PASSWORD:-}" ]] || { echo 'Password cannot be blank' >&2; exit 1; }
kubectl create secret generic mysql-credentials   --from-literal="MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"   --dry-run=client -o yaml | kubectl apply -f -
unset MYSQL_ROOT_PASSWORD
echo 'Secret/mysql-credentials created. Avoid pasting passwords in commands or Git.'
