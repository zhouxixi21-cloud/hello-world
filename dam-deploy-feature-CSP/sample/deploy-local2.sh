#!/bin/bash
# this script deploys all applications needed for SiteSmart project.  Assumed called as a PUSH deploy as nexus is NOT
# visible from AWS
set -o nounset
set -o errexit

if [ $# -ne 2 ]; then
  echo "Usage: ./deploy.sh <version> <stack>"
  exit 1
fi

# set deploy arguments
version=$1
stack=$2
nexus_host='nexus.sensis.com.au'
nexus_port=8081
nexus_repository='sitesmart-releases'

function checkResult() {
 result=$1
 echo "Result code is ${result}"
 if [[ ${result} -ne 0 ]]; then
    echo "Result code failure:  result is ${result}"
    exit ${result}
 fi
}

# set file path where artifact files will be downloaded to
# this path is unique to avoid multiple deployment from modifying the same file
timestamp=`date +"%s"`
export file_path="/tmp/sitesmart-deployer-${timestamp}"
mkdir -p ${file_path}
# The jenkins part of provision requires the correct version of deployer in the file path directory so the pom is available.
echo "Retrieving deployer ${version} for SiteSmart ${version}"
cd $file_path
wget -O "deployer-${version}.zip" --no-proxy "http://${nexus_host}:${nexus_port}/nexus/service/local/artifact/maven/content?r=${nexus_repository}&g=au.com.sensis.sitesmart&a=deployer&e=zip&v=${version}"
unzip $file_path/deployer-${version}.zip -d $file_path

export crx_username=${crx_username:-admin}
export crx_password=${crx_password:-$stack-admin#}

deploy-app.sh sitesmart-provision-author $version $stack
deploy-app.sh sitesmart-provision-publisher $version $stack
deploy-app.sh sensis-aem-core $version $stack
deploy-app.sh sitesmart-aem-core $version $stack
deploy-app.sh sitesmart-aem-tools $version $stack
# NOTE: the following apps are pull-deployed via AWS controlbox's appdeployrun:
#       - sitesmart-aem-dispatcher author
#       - sitesmart-aem-dispatcher-publisher

checkResult $?
rm -rf ${file_path}
