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
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

fullpathofapptoadd=""
whichend=""
dockitemname=""

[ "$4" != "" ] && [ "$fullpathofapptoadd" == "" ] && fullpathofapptoadd=$4
[ "$5" != "" ] && [ "$dockitemname" == "" ] && dockitemname=$5

if [ ! -f "$dockutilapp" ]; then
  jamf policy -trigger main_dockutil
fi

dock_item_find=$(sudo -u $loggedInUser $dockutilapp --find "$dockitemname")

if [[ $dock_item_find == *was\ found* ]]; then
        #dock item is found
        echo "Skipping '$dockitemname' (Item already in dock)."
    else
        #dock item is not found
        echo "$dockitemname not in dock. Adding to beginning..."
        $dockutilapp --add "$fullpathofapptoadd" --position beginning /Users/$loggedInUser
fi
