#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to grab a file, append the date to it and upload to the computer record in JAMF.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#

serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $NF}')
getDate=$(date "+%Y-%m-%d")
jamfURL="myjss.jamfcloud.com"

apiUser=""
apiPass=""
filePath=""
fileName=""

[ "$4" != "" ] && [ "$apiUser" == "" ] && apiUser=$4
[ "$5" != "" ] && [ "$apiPass" == "" ] && apiPass=$5
[ "$6" != "" ] && [ "$filePath" == "" ] && filePath=$6
[ "$7" != "" ] && [ "$fileName" == "" ] && fileName=$7

cp "$filePath""$fileName" "$filePath""$getDate""$fileName"


jamfID=$(curl -su $apiUser:$apiPass -H "accept: text/xml" https://$jamfURL/JSSResource/computers/serialnumber/$serialNumber | xmllint --xpath '/computer/general/id/text()' -)

curl -su $apiUser:$apiPass https://$jamfURL/JSSResource/fileuploads/computers/id/$jamfID -F name=@"$filePath""$getDate""$fileName" -X POST
