#!/bin/bash

#
# DESCRIPTION
#
# 	Toggles the pasword expiration countdown on or off.
#

launchAgent="/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist"
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
loggedInUID=$(id -u $loggedInUser)
currentSetting=$(defaults read /Users/$loggedInUser/Library/Preferences/com.trusourcelabs.NoMAD.plist HideExpiration)

# unload NoMAD so it doesn't attempt to read or write to the plist we are editing
launchctl bootout gui/$loggedInUID $launchAgent

# toggle the setting
if [[ $currentSetting == 1 ]]; then
  echo "Current setting is $currentSetting..."
  echo "Changing to 0..."
  defaults write /Users/$loggedInUser/Library/Preferences/com.trusourcelabs.NoMAD.plist HideExpiration 0
else
  echo "Current setting is $currentSetting..."
  echo "Changing to 1..."
  defaults write /Users/$loggedInUser/Library/Preferences/com.trusourcelabs.NoMAD.plist HideExpiration 1
fi

# change ownership back to user
chown $loggedInUser /Users/$loggedInUser/Library/Preferences/com.trusourcelabs.NoMAD.plist
chmod 755 /Users/$loggedInUser/Library/Preferences/com.trusourcelabs.NoMAD.plist

# clear cached preferences
su $loggedInUser -c 'killall cfprefsd'
killall cfprefsd

# reload NoMAD now we are done
launchctl bootstrap gui/$loggedInUID $launchAgent
