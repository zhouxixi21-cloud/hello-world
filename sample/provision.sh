#!/bin/bash
# this script provisions aem with Sensis Health page/change admin password/create utility users and change passwords
# it is possible that this script will be executed multiple times, e.g. when a password is updated, or when replication agents have to be rebuilt
# provision step is separate from cluster step because provision can be executed multiple times, while cluster step is once only
set -o errexit

if [ "$crx_old_password" == "" ]
then
  echo "[ERROR] crx_old_password environment variable required"
  exit 1
fi
if [ "$crx_new_password" == "" ]
then
  echo "[ERROR] crx_new_password environment variable required"
  exit 1
fi


if [ $# -ne 2 ]; then
  echo "Usage: ./provision.sh <version> <stack>"
  exit 1
fi

# set deploy arguments
version=$1
stack=$2
nexus_host='nexus.sensis.com.au'
nexus_port=8081
nexus_repository='sitesmart-releases'
if [[ ${version} == *SNAPSHOT* ]]; then
    nexus_repository='sitesmart'
fi

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
export file_path="/tmp/sitesmart-deployer-$timestamp"
mkdir -p "$file_path"

# The jenkins part of provision requires the correct version of deployer in the file path directory so the pom is available.
echo "Retrieving deployer ${version} for SiteSmart ${version}"
cd $file_path
wget -O "deployer-${version}.zip" --no-proxy "http://${nexus_host}:${nexus_port}/nexus/service/local/artifact/maven/content?r=${nexus_repository}&g=au.com.sensis.sitesmart&a=deployer&e=zip&v=${version}"
unzip $file_path/deployer-${version}.zip -d $file_path

# NOTE: sensis-aem-core is deployed twice because:
# - the first deployment is used to create system users (dispatcher and deployer), which need to exist before aem-provision steps,
#   and also to provide master health servlet for the write load balancer to use
# - the second deployment is used to replicate sensis-aem-core since the replication agents would've been created by aem-provision steps
# TODO: simplify this, we want to deploy sensis-aem-core just once
crx_password=$crx_old_password deploy-app.sh sensis-aem-core $version $stack
crx_password=$crx_old_password deploy-app.sh aem-provision-author $version $stack
crx_password=$crx_old_password deploy-app.sh aem-provision-publisher $version $stack
crx_password=$crx_new_password deploy-app.sh sensis-aem-core $version $stack
# crx_password=$crx_new_password ./deploy-app.sh sensis-aem-hotfixes $version $stack

checkResult $?
rm -rf ${file_path}
