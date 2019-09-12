#!/bin/bash
source "scripts/include-functions.sh"

# Deploy SiteSmart applications in a local environment (AEM running on developer's machine)
# Note that the applications will be downloaded from Nexus, not from locally git-cloned source on developer's machine
set -o nounset
set -o errexit

# set file path where artifact files will be downloaded to
# this path is unique to avoid multiple deployment from modifying the same file
timestamp=`date +"%s"`
file_path="/tmp/sitesmart-deployer"

# setup local deployment
mkdir -p ${file_path}
rsync -a --delete . ${file_path}

stack=local
if [ $# -ne 1 ]; then
    version=`/usr/bin/python lib/deployer-version.py ${file_path}`
else
    version=$1
fi

echo "Installing deployer version $version"

# local should never use proxy
unset http_proxy
unset https_proxy

# local environment uses the out-of-the-box admin/admin credential
export crx_username=admin
export crx_password=admin
export file_path=$file_path

# needed by local dispatcher deployment
export connection_type=local

export PYTHONPATH=../../lib/python-packages

#./deploy-app.sh monitor-installer $version $stack
deploy-app.sh sitesmart-provision-author $version $stack
#./deploy-app.sh sitesmart-content-permissions $version $stack
deploy-app.sh sitesmart-provision-publisher $version $stack
deploy-app.sh sensis-aem-core $version $stack
deploy-app.sh sitesmart-aem-core $version $stack

if [ "$OS" == "mac" ]; then

	echo "********************************************************************"
	echo " WARN: MAC OSX Skipping httpd config, please do it manualy"
	echo " Path: $file_path-/tmp/sitesmart-deployer/sitesmart-aem-dispatcher-publisher-$version/src"
	echo "********************************************************************"

else

deploy-app.sh sitesmart-aem-dispatcher-publisher $version $stack

fi

deploy-app.sh sitesmart-migration $version $stack
