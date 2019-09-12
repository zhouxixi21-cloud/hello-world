#!/bin/bash
source "scripts/include-functions.sh"

# Deploy a single SiteSmart application

set -o errexit

if [ $# -lt 3 ]; then
  echo "Usage: ./deploy-app.sh <application> <version> <stack>"
  exit 1
fi

application=$1
version=$2
stack=$3

# use file path from environment variable (set uniquely per sitesmart deployment in the client script e.g. deploy.sh, aws-deploy-template.sh, and provision.sh)
# if this deploy-app.sh script is called directly and there's no set file_path, then fallback to /tmp/sitesmart-deployer
echo "File path is ${file_path}"
file_path=${file_path:-/tmp/sitesmart-deployer}
echo "File path is now ${file_path}"

# needed by local deployment of dispatcher (this won't be needed if we ever move to virtualboxes for local environment)
connection_type=${connection_type:-paramiko}

export crx_username=${crx_username:-admin}
export crx_password=${crx_password:-$stack-admin#}

mkdir -p $file_path

# if [ "${application}" = "sensis-aem-core" -o "$application" = "sitesmart-aem-core" ]; then

componentVersion=${version}
mavenComponents=('sensis-aem-core' 'sitesmart-aem-core' 'sitesmart-aem-dispatcher-publisher' 'sitesmart-aem-dispatcher-author' 'sitesmart-aem-dispatcher-customer' 'sitesmart-aem-tools' 'monitor-installer')
for i in "${mavenComponents[@]}"
do
    if [ "$i" == "${application}" ] ; then
        componentName="${application}"
        if [[ "${componentName}" == *aem-core*  ]]; then
            componentName="${application}-content"
        fi
        componentVersion=`/usr/bin/python lib/parse-pom.py ${componentName} ${file_path}`
    fi
done
echo "Deploying sitesmart app version: $version, on stack: $stack, with file path: $file_path, component: $application, component version: ${componentVersion}"

if [ "$OS" == "mac" ]; then

	pythonLocalPackages=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
    PYTHONPATH=$PYTHONPATH:$pythonLocalPackages

	echo "********************************************************************"
	echo " INFO: MAC - Resolved Python Libs"
	echo "Resolved: $pythonLocalPackages"
	echo "Full Path: $PYTHONPATH"
	echo "********************************************************************"

fi

PYTHONPATH=$PYTHONPATH:../../lib/python-packages \
ansible-playbook \
  -vvvvvv \
  --extra-var="application=$application version=$componentVersion stack=$stack file_path=$file_path connection_type=$connection_type crx_old_password=$crx_old_password crx_new_password=$crx_new_password" \
  --inventory components/$application/hosts \
  components/$application/playbook.yml
