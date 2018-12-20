#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to populate menu.nomad.shares.plist with values.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#   Requites Yo to be installed for success notification
#

launchAgent="/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist"
sharesPlist="/Library/Preferences/menu.nomad.shares.plist"
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
loggedInUID=$(id -u $loggedInUser)
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper"
jamfhelpericon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns"

shareName=""		#	"string"
shareUrl=""		#	"string"


[ "$4" != "" ] && [ "$shareName" == "" ] && shareName=$4
[ "$5" != "" ] && [ "$shareUrl" == "" ] && shareUrl=$5

# check to see if menu.nomad.shares.plist exists and create with Shares array and Version if not
if [[ ! -f $sharesPlist ]]; then
  echo "Shares preference file does not exist..."
  echo "Creating menu.nomad.shares.plist"
  defaults write $sharesPlist Shares -array
  defaults write $sharesPlist Version 1
fi

# grab the number of existing shares so we know what number of the array to add the new one
numberOfShares=$(defaults read $sharesPlist Shares | Grep -c Name)

# check if the share already exixts, if so quit out so we dont add it again
shareExists=$(defaults read $sharesPlist Shares | Grep "$shareName")
if [[ $shareExists != "" ]]; then
  echo "Share already exists..."
  echo "Notifying user..."
  $jamfHelper -windowType utility -title "IT" -description "File Share already exists in NoMAD. If you cannot see it please contact the Service Desk"  -icon "$jamfhelpericon" -button1 "Ok" -defaultButton 1
  echo "Exiting..."
  exit 0
fi

# unload NoMAD so it doesn't attempt to read or write to the plist we are editing
launchctl bootout gui/$loggedInUID $launchAgent

# insert the new share dict to the Shares array
echo "Creating share in array $numberOfShares..."
plutil -insert Shares.$numberOfShares -xml "<dict><key>AutoMount</key><false/><key>ConnectedOnly</key><true/><key>Groups</key><array/><key>LocalMount</key><string></string><key>Name</key><string>$shareName</string><key>Options</key><array/><key>URL</key><string>smb://$shareUrl</string></dict>" $sharesPlist
echo "Share created..."

# clear cached preferences
su $loggedInUser -c 'killall cfprefsd'
killall cfprefsd

# reload NoMAD now we are done
launchctl bootstrap gui/$loggedInUID $launchAgent

echo "Notifying user..."
su $loggedInUser -c '/usr/local/bin/yo_scheduler -t "File Share Added to NoMAD" -n "You can now access this from the NoMAD menu bar"'
