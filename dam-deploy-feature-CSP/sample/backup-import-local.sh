#!/bin/bash
# Executes AEM data import from one stack to another stack
set -o nounset
set -o errexit

if [ $# -ne 3 ]; then
  echo "Usage: ./backup-import-local.sh <yyyymmdd> <stack> <debug:true/false>"
  exit 1
fi

timestamp=$1
stack=$2


packageName="sitesmart-aem-data-author-01"
packageNameZip="sitesmart-aem-data-author-01-$timestamp.zip"
packageGroup="sitesmart"
package="$packageName-$timestamp.zip"
packageFullPath="import/$package"
#package="$packageName.zip"
#packageFullPath="import/$timestamp/$package"

export crx_port=${crx_username:-4502}
export crx_host=${crx_username:-localhost}
export crx_username=${crx_username:-admin}
export crx_password=${crx_password:-admin}

flagDebug=$3
function debug {
	if [ $flagDebug == "true" ]; then	
		echo $1
	fi
}

#debugIf(conditionResult,success,fail)
function debugIf
{
	case $1 in
		(true) echo " - " $2;;
		(false) echo " - " $3;;
	esac
}
#findInString(source,search,success,fail)
function findInString {
	echo $1
	if [[ "$1" =~ "$2" ]]; then
		echo true
	else
		echo false
	fi
}

#findNotInString(source,search,success,fail)
function findInString {
	if [[ "$1" =~ "$2" ]]; then
		echo false
	else
		echo true
	fi
}

#isPackageExists packageName
function isPackageExists {
	packageCheckCommand="curl -s -u admin:admin -F cmd=ls http://localhost:4502/crx/packmgr/service.jsp"
	packageCheck=$($packageCheckCommand)
	foundPackage=$(printf "$packageCheck" | grep "<name>$1</name>" | sed 's/.*<name>\([^<]*\)<.*/\1/')

	if [[ "$1" == "$foundPackage" ]]; then
		echo true
	else
		echo false
	fi
}

#isPackageInstalled packageName
function isPackageInstalledByName {
	packageCheckCommand="curl -s -u admin:admin -F cmd=ls http://localhost:4502/crx/packmgr/service.jsp"
	packageCheck=$($packageCheckCommand)
	foundPackage=$(printf "$packageCheck" | grep "<name>$1</name>" -B 1 -A 9 )
	foundPackageLUB=$(printf "$foundPackage" | grep "<lastUnpackedBy>" | sed 's/.*<lastUnpackedBy>\([^<]*\)<.*/\1/' )

	if [[ "$foundPackage" =~ "$1" ]]; then
		if [[ "$foundPackageLUB" == "null" ]]; then
			echo false
		else
			echo true
		fi
	else
		echo false
	fi
}

#isPackageInstalled packageName
function isPackageInstalledByFileName {
	packageCheckCommand="curl -s -u admin:admin -F cmd=ls http://localhost:4502/crx/packmgr/service.jsp"
	packageCheck=$($packageCheckCommand)
	foundPackage=$(printf "$packageCheck" | grep "<downloadName>$1</downloadName>" -B 1 -A 9 )
	foundPackageLUB=$(printf "$foundPackage" | grep "<lastUnpackedBy>" | sed 's/.*<lastUnpackedBy>\([^<]*\)<.*/\1/' )

	if [[ "$foundPackage" =~ "$1" ]]; then
		if [[ "$foundPackageLUB" == "null" ]]; then
			echo false
		else
			echo true
		fi
	else
		echo false
	fi
}

#uninstallPackage packageName
function uninstallPackage {
	uninstallCommand="curl \
		-s \
		-u $crx_username:$crx_password \
		-F name=$1 \
		-F cmd=uninst \
		http://localhost:4502/crx/packmgr/service.jsp"

	packageCheck=$($uninstallCommand)

	uninstallCheckString="<status code=\"200\">ok</status>"

	if [[ $packageCheck =~ $uninstallCheckString ]]
	then
	  	echo true
	else
		echo false
	fi
}

#removePackage packageName
function removePackage {
	removeCommand="curl \
		-s \
		-u $crx_username:$crx_password \
		-F name=$1 \
		-F cmd=rm \
		http://localhost:4502/crx/packmgr/service.jsp"

	packageCheck=$($removeCommand)
	removeCheckString="<status code=\"200\">ok</status>"
	if [[ $packageCheck =~ $removeCheckString ]]
	then
	  	echo true
	else
		echo false
	fi
}

#installPackage packageName
function installPackage {

	#Install Package
	installCommand="curl \
		-s \
		-u $crx_username:$crx_password \
		-F name=$1 \
		-F cmd=inst \
		http://localhost:4502/crx/packmgr/service.jsp"


	installStatus=$($installCommand)

	installCheckString="<status code=\"200\">ok</status>"

	if [[ $installStatus =~ $installCheckString ]]
	then
		echo true
	else
		echo false
	fi


}

#uploadPackage packageName, packageFileName 
function uploadPackage {

	#Upload Package

	uploadCommand="curl \
		-s \
		-u $crx_username:$crx_password \
		-X POST \
		-F file=@$2 \
		-F name=$1 \
		-F force=true \
		-F install=false \
		-F cmd=upload \
		http://localhost:4502/crx/packmgr/service.jsp"


	uploadStatus=$($uploadCommand)

	uploadCheckString="<status code=\"200\">ok</status>"
	if [[ $uploadStatus =~ $uploadCheckString ]]
	then
	  	echo true
	else
		echo false
	fi
}


function jsonval {
    temp=$(printf "$1" | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2)
    echo ${temp##*|}
}

function migrateContent {
	migrateCommand="curl -s -u $crx_username:$crx_password -X POST http://$crx_host:$crx_port/bin/ssapi/v1/migrate?action=start"
	migrateStatus=$($migrateCommand)

	result=$(jsonval "$migrateStatus" "processCount")
	echo $result

}

debug ""
debug "<START>"
debug ""
debug "Starting"
startUploaded=$(isPackageExists "$packageName")
startInstalled=$(isPackageInstalledByName "$packageName")

debug "Is Package Already uploaded: $startUploaded"
debug "Is Package Already installed: $startInstalled" 

case $startUploaded in
	(true)
        debug "Uninstalling...";
		case $startInstalled in
			(true) debug "Uninstall and Remove: $(uninstallPackage "$packageName") $(removePackage "$packageName")";;
			(false) debug "Remove: $(removePackage "$packageName")";;
		esac ;;
	(false) debug "Will upload...";;
esac

#sleep 5s
debug "Uploading..."

uploadStatus=$(uploadPackage "$packageName" "$packageFullPath")

debug "Uploaded: $uploadStatus"

uploadIsUploaded=$(isPackageExists "$packageName")
debug "Is Uploaded: $uploadIsUploaded"


#debug "Waiting before install 20s..."
#sleep 20s
#sleep 5s
debug "Installing..."

installStatus=$(installPackage "$packageName")
uploadInstalled=$(isPackageInstalledByName "$packageName")
debug "Is Installed: $uploadInstalled" 

#MIGRATING
debug "Migrating"
migrateStatus=$(migrateContent)
debug "Migration Status:"
#debug "$migrateStatus"

for line in $migrateStatus; do printf "$line\n"; done;

debug ""
debug "<END>"
debug ""


# #help
# curl -v -u admin:admin -F cmd=help http://localhost:4502/crx/packmgr/service.jsp

# +------------+-----------------------------------------+ 
# |  Arguments | Comment                                 | 
# +------------+-----------------------------------------+ 
# |  cmd=help  | print this help                         | 
# +------------+-----------------------------------------+ 
# |  cmd=ls    | print a list of all packages            | 
# +------------+-----------------------------------------+ 
# |  cmd=rm    | remove a  package                       | 
# |  name      | package name                            | 
# |  [group]   | group name (optional)                   | 
# +------------+-----------------------------------------+ 
# |  cmd=build | build a  package                        | 
# |  name      | package name                            | 
# |  [group]   | group name (optional)                   | 
# +------------+-----------------------------------------+ 
# |  cmd=inst  | install a package                       | 
# |  name      | package name                            | 
# |  [group]   | group name (optional)                   | 
# +------------+-----------------------------------------+ 
# |  cmd=uninst| uninstall a package                     | 
# |  name      | package name                            | 
# |  [group]   | group name (optional)                   | 
# +------------+-----------------------------------------+ 
# |  GET       | download a package                      | 
# |            | (content-disposition header contains    | 
# |            | the correct filename)                   | 
# |  [cmd=get] | optional                                | 
# |  name      | package name                            | 
# |  [group]   | group name (optional)                   | 
# +------------+-----------------------------------------+ 
# |  POST      | upload a new package                    | 
# |  file      | package to upload                       | 
# |  [name]    | optional name                           | 
# |  [install] | automatically install package if 'true' | 
# +------------+-----------------------------------------+

