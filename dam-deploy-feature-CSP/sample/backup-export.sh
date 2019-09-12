#!/bin/bash
# Executes AEM data export from a specified stack
set -o nounset
set -o errexit

if [ $# -ne 2 ] && [ $# -ne 1 ]; then
  echo "Usage: ./backup-export.sh <stack> [package_version]"
  exit 1
fi

stack=$1

if [ $# -eq 1 ]; then
  package_version=`date +'%Y%m%d'`
else
  package_version=$2
fi

export crx_username=${crx_username:-admin}
export crx_password=${crx_password:-$stack-admin#}

ansible-playbook \
  --extra-var="stack=$stack package_version=$package_version" \
  --inventory components/sitesmart-backup-export/hosts \
  --verbose \
  components/sitesmart-backup-export/playbook.yml