#!/bin/bash
# this script sets up AEM cluster
# - once during initial stack creation
# - on daily startup for non-prod environment
set -o nounset
set -o errexit

if [ $# -ne 1 ]; then
  echo "Usage: ./install-hotfixes-author.sh <stack>"
  exit 1
fi

stack=$1
version=1.0-SNAPSHOT
export crx_username=${crx_username:-admin}
export crx_password=${crx_password:-admin}
export PYTHONPATH=../../lib/python-packages

file_path=${file_path:-/tmp/sitesmart-deployer}
mkdir -p ${file_path}
rsync -a --delete . ${file_path}


extra_var="crx_username=$crx_username crx_password=$crx_password stack=$stack file_path=${file_path}"

# Verify the author nodes are up
ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-author/hosts \
  components/aem-hotfixes-author/playbook.yml -vvvvv --tags "verify"

# Download hotfixes from Nexus
ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-author/hosts \
  components/aem-hotfixes-author/playbook.yml -vvvvv --tags "download-hotfixes"

# Upload/install hotfixes on author
ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-author/hosts \
  components/aem-hotfixes-author/playbook.yml -vvvvv --tags "run-hotfixes"
