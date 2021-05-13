#!/bin/bash

#
# SYNOPSIS - How to use
#	  Run via a policy to remove app from dock.
#   https://github.com/kcrawford/dockutil needs to be instlled on the Mac
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#

dockutilapp=/usr/local/bin/dockutil
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}   ' )

bundleID=""

[ "$4" != "" ] && [ "$bundleID" == "" ] && bundleID=$4
[ "$5" != "" ] && [ "$dockitemname" == "" ] && dockitemname=$5

if [ ! -f "$dockutilapp" ]; then
  jamf policy -trigger main_dockutil
fi

dock_item_find=$(sudo -u $loggedInUser $dockutilapp --find "$dockitemname")

if [[ "$dock_item_find" == *was\ found* ]]
    then
        #dock item is found
        echo "Removing '$bundleID' from dock..."
        $dockutilapp --remove $bundleID
        echo "'$bundleID' removed from dock."
    else
        #dock item is not found
        echo "'$dockitemname' not in dock."
fi