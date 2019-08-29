#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to add or remove app from dock.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#

dockutilapp=/usr/local/bin/dockutil
loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

fullpathofapptoadd=""
whichend=""
dockitemname=""

[ "$4" != "" ] && [ "$fullpathofapptoadd" == "" ] && fullpathofapptoadd=$4
[ "$5" != "" ] && [ "$dockitemname" == "" ] && dockitemname=$5

# Install dockutil if it doesn't exist
if [ ! -f "$dockutilapp" ]; then
  jamf policy -trigger main_dockutil
fi

dock_item_find=$(sudo -u $loggedInUser $dockutilapp --find "$dockitemname")

if [[ "$dock_item_find" == *was\ found* ]]
    then
        #dock item is found
        echo "Skipping '$dockitemname' (Item already in dock)."
    else
        #dock item is not found
        echo "'$dockitemname' not in dock. Adding to beginning..."
        $dockutilapp --add "$fullpathofapptoadd" --position beginning /Users/$loggedInUser
fi
