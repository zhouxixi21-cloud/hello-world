#!/bin/bash
source "scripts/include-functions.sh"

# Executes AEM data import from one stack to another stack
set -o nounset
set -o errexit

if [ $# -ne 3 ]; then
  echo "Usage: ./backup-import.sh <timestamp> <from_stack> <to_stack>"
  exit 1
fi

timestamp=$1
from_stack=$2
to_stack=$3

export crx_username=${crx_importer_username:-admin}
export crx_password=${crx_importer_password:-$stack-admin#}

ansible-playbook \
  --extra-var="stack=$to_stack from_stack=$from_stack package_version=$timestamp importer_aem_password=$crx_password" \
  --inventory components/sitesmart-backup-import/hosts \
  --verbose \
  components/sitesmart-backup-import/playbook.yml


PYTHONPATH=""

if [ "$OS" == "mac" ]; then

	pythonLocalPackages=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
    PYTHONPATH=$PYTHONPATH:$pythonLocalPackages

	echo "********************************************************************"
	echo " INFO: MAC - Resolved Python Libs"
	echo "Resolved: $pythonLocalPackages"
	echo "Full Path: $PYTHONPATH"
	echo "********************************************************************"

fi

export crx_username=${crx_permissions_username:-admin}
export crx_password=${crx_permissions_password:-$stack-admin#}

PYTHONPATH=$PYTHONPATH:../../lib/python-packages \
ansible-playbook \
  --extra-var="stack=$to_stack " \
  --inventory components/sitesmart-content-permissions/hosts \
  --verbose \
  components/sitesmart-content-permissions/playbook.yml

