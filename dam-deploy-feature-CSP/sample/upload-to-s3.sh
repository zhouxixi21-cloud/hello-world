#! /bin/bash
# Download artifact from Nexus and upload it to S3.
set -o nounset
set -o errexit

if [ $# -ne 2 ]; then
  echo "Usage: ./upload-to-s3.sh <application> <version>"
  exit 1
fi

aws_account=naws
project_name=sitesmart

application=$1
version=$2

gitorious_host=gitorious.int.sensis.com.au
nexus_host=nexus.sensis.com.au
nexus_port=8081

tmp_dir=target/sitesmart-release
rm -rf $tmp_dir
mkdir -p $tmp_dir

# read application's info.json file and parse the filtered value
app_info () {
	application=$1
	filter=$2
	cat components/$application/info.json | ./bin/jq --raw-output "$filter"
}

nexus_repository=`app_info $application '.nexus.repository'`
nexus_group=`app_info $application '.nexus.group'`
nexus_artifact=`app_info $application '.nexus.artifact'`
nexus_ext=`app_info $application '.nexus.ext'`
s3_bucket=`app_info $application '.s3.bucket'`
s3_artifact=`app_info $application '.s3.artifact'`


# prepare aws-controller (used for interacting with AWS control box - uploading artifact to s3)
echo "Cloning/pull-rebasing aws-controller from Gitorious"
if [ -d "$tmp_dir/aws-controller" ]; then
  cd $tmp_dir/aws-controller && git pull --rebase origin master && cd ../../..
else
  cd $tmp_dir && git clone git@$gitorious_host:sitesmart-platform/aws-controller.git aws-controller && cd ../..
fi

# download artifact from Nexus and upload artifact to s3 using aws-controller
# - downloading the artifact from Nexus is needed because it's the consistent way to retrieve the artifact for all applications
# - we can't rely on filesystem because not all applications have the artifact at the same target location, and the artifact name is not always the name in the parent pom
# - we also can't use each application's Maven to publish to s3 due to security layer on AWS control box, we have to use aws-controller to interact with it, build box can't access S3
wget \
"http://$nexus_host:$nexus_port/nexus/service/local/artifact/maven/content?r=$nexus_repository&g=$nexus_group&a=$nexus_artifact&e=$nexus_ext&v=$version" \
--output-document=$tmp_dir/$nexus_artifact-$version.$nexus_ext
cd $tmp_dir/aws-controller
./build-upload.sh $aws_account $project_name $version ../../$nexus_artifact-$version.$nexus_ext
cd ../../..

if [ $application = "deployer" ]; then
	cp aws-deploy.sh $tmp_dir/deploy.sh
	sed -i "s/{{ version }}/$version/g" $tmp_dir/deploy.sh
	cd $tmp_dir/aws-controller
	./build-upload.sh $aws_account $project_name $version ../../deploy.sh
	cd ../../..	
fi