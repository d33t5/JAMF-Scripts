#!/bin/bash
#
# SYNOPSIS - How to use
#	Run via a policy to write to DEP Notify.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#   Store icon files for use in $configFolder/icons.

configFolder="/Library/Application Support/Corp"
depNotifyLog="/var/tmp/depnotify.log"
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}   ' )

imageFileName=""	#	"string"
mainTitle=""		#	"string"
mainText=""			#	"string"

[ "$4" != "" ] && [ "$imageFileName" == "" ] && imageFileName=$4
[ "$5" != "" ] && [ "$mainTitle" == "" ] && mainTitle=$5
[ "$6" != "" ] && [ "$mainText" == "" ] && mainText=$6

echo "Command: Image: "$configFolder"/icons/$imageFileName" >> $depNotifyLog
echo "Command: MainTitle: $mainTitle" >> $depNotifyLog
echo "Command: MainText: $mainText" >> $depNotifyLog