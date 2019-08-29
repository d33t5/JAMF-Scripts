#!/bin/bash
#
# SYNOPSIS - How to use
#	Run via a policy to populate Yo with values to present messages to the user.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#

loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

title=""			#	"string"
information=""		#	"string"
button=""			#	"string"
action=""			#	path

[ "$4" != "" ] && [ "$title" == "" ] && title=$4
[ "$5" != "" ] && [ "$information" == "" ] && information=$5
[ "$6" != "" ] && [ "$button" == "" ] && button=$6
[ "$7" != "" ] && [ "$action" == "" ] && action=$7

# Clear any pending notifications
/usr/local/bin/yo_scheduler --cleanup

# Remove prefs to get around the one time notification issue
rm /Library/Preferences/com.sheagcraig.yo.plist
rm /Users/$loggedInUser/Library/Preferences/com.sheagcraig.yo.plist

/usr/local/bin/yo_scheduler -t "$title" -n "$information" -b "$button" -a "$action"
