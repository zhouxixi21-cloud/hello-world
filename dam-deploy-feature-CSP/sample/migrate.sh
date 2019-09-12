#!/bin/bash
set -o errexit

if [ $# -ne 1 ]; then
  echo "Usage: ./migrate.sh <stack>"
  exit 1
fi

stack=$1

export crx_username=${crx_username:-admin}
export crx_password=${crx_password:-$stack-admin#}

PYTHONPATH=../../lib/python-packages \
ansible-playbook \
  --extra-var="stack=$stack" \
  --inventory components/sitesmart-migration/hosts \
  --verbose \
  components/sitesmart-migration/playbook.yml