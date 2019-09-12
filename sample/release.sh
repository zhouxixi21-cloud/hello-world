#! /bin/bash
# Release SiteSmart applications by:
# 1. Downloading source code from Gitorious
# 2. Package the code and publish the artifact into Nexus
# 3. Upload the artifact into Amazon S3
set -o nounset
set -o errexit

if [ $# -ne 1 ]; then
  echo "Usage: ./release.sh <version>"
  exit 1
fi

aws_account=naws
project_name=sitesmart
project_version=$1

gitorious_host=gitorious.int.sensis.com.au

tmp_dir=target/sitesmart-release
mkdir -p $tmp_dir


# read application's info.json file and parse the filtered value
app_info () {
	application=$1
	filter=$2
	cat components/$application/info.json | ./bin/jq --raw-output "$filter"
}


# prepare aws-controller (used for interacting with AWS control box - uploading artifact to s3)
echo "Cloning/pull-rebasing aws-controller from Gitorious"
if [ -d "$tmp_dir/aws-controller" ]; then
  cd $tmp_dir/aws-controller && git pull --rebase origin master && cd ../../..
else
  cd $tmp_dir && git clone git@$gitorious_host:sitesmart-platform/aws-controller.git aws-controller && cd ../..
fi


# release all SiteSmart applications
for APPLICATION in sitesmart-aem-functional-test sensis-aem-core sitesmart-aem-core sitesmart-aem-dispatcher-author sitesmart-aem-dispatcher-publisher sitesmart-aem-tools deployer aws-controller 
do

  echo "########################################################################"
  echo "## $APPLICATION"
  echo "########################################################################"

  # parse application info
  echo "Parsing application info.json"
  gitorious_project=`app_info $APPLICATION '.gitorious.project'`
  gitorious_repository=`app_info $APPLICATION '.gitorious.repository'`

  cd $tmp_dir

  # clone source code from Gitorious, jump to application directory
  echo "Cloning/pull-rebasing $APPLICATION from Gitorious"
  if [ -d "$APPLICATION" ]; then
    cd $APPLICATION && git pull --rebase origin master
  else
    git clone git@$gitorious_host:$gitorious_project/$gitorious_repository.git $APPLICATION && cd $APPLICATION
  fi
  echo "Last commit hash:"
  git log -1 --format="%H"

  # set version and publish to Nexus
  echo "Set application version and publish to Nexus"
  mvn -DnewVersion=$project_version -DgenerateBackupPoms=false clean versions:set
  mvn -DskipTests -DskipITs=true deploy

  # tag application source code
  git tag -a $project_version -m "Tag $project_version"
  git push --tags

  cd ../../..

  # upload application artifact to S3, used for AWS pull-based deployment
  upload-to-s3.sh $APPLICATION $project_version

  # fail immediately out of loop when there's any failure, otherwise the loop swallows the non-zero exit code
  if [ $? -ne 0 ]; then
    break;
  fi

done
