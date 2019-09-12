#!/bin/bash
# this script sets up AEM cluster
# - once during initial stack creation
# - on daily startup for non-prod environment
set -o nounset
set -o errexit

if [ $# -ne 1 ]; then
  echo "Usage: ./install-hotfixes-publisher.sh <stack>"
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

# Start publihser nodes
if [[ $stack != "local" && $stack != "docker" ]] ; then
  ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-publisher/hosts \
    components/aem-hotfixes-publisher/playbook.yml -vvvvv --tags "start-publisher"
fi

# Verify the publisher nodes are up
ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-publisher/hosts \
  components/aem-hotfixes-publisher/playbook.yml -vvvvv --tags "verify"

# Download hotfixes from Nexus
ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-publisher/hosts \
  components/aem-hotfixes-publisher/playbook.yml -vvvvv --tags "download-hotfixes"

# Upload/install hotfixes on publisher
ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-publisher/hosts \
  components/aem-hotfixes-publisher/playbook.yml -vvvvv --tags "run-hotfixes"

if [[ $stack != "local" && $stack != "docker" ]] ; then
  ansible-playbook --extra-var="$extra_var" -i components/aem-hotfixes-publisher/hosts \
    components/aem-hotfixes-publisher/playbook.yml -vvvvv --tags "stop-publisher"
fi
