#!/bin/bash


# bypolicySoftwareUpdateAndNotify
# finds out if app is running if so kills it then removes the app, this is prior to an
# update being installed


# examples
# nameofapp=Firefox (this is for user prompts)
# process=firefox-bin (find by running top or ps)
# fullpathofapptoremove="/Applications/App Store"

nameofapp=""
fullpathofapptoremove=""
fullpathofapptoremove=""

[ "$4" != "" ] && [ "$nameofapp" == "" ] && nameofapp=$4
[ "$5" != "" ] && [ "$process" == "" ] && process=$5
[ "$6" != "" ] && [ "$fullpathofapptoremove" == "" ] && fullpathofapptoremove=$6

apprunning=`pgrep -x "$process"`
jamfhelperrunning=`pgrep jamfhelper`
loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )


echo "User logged in running update = $loggedInUser"
echo "Looking for Process $process"

# uncomment these if you just want to kill the app rather than notify user
#if [ "$apprunning" != "" ]; then
#echo "$process is still running, killing it..."
#killall "$processtokill"
#fi

# check process is not running or notify user
while [ "$apprunning" != "" ]; do
apprunning=`pgrep "$process"`

echo "$process is still running, notifying user..."

# display message in jamf helper to user
jamf displayMessage -message "$nameofapp cannot be open during installation.

Please quit $nameofapp and the update will continue."

sleep 5

apprunning=`pgrep "$process"`
jamfhelperrunning=`pgrep jamfHelper`
done

if [[ $jamfhelperrunning != "" ]]
then
killall jamfHelper
fi

echo "$process is not running"

# remove old version before new installation
if [ "$fullpathofapptoremove" = "" ]; then
echo "No path set to remove anything before installation"
else
	echo "Removing old version at $fullpathofapptoremove"
	if [ -d "$fullpathofapptoremove" ]; then
	echo "Old version present at $fullpathofapptoremove, removing..."
	rm -R "$fullpathofapptoremove"
	echo "$fullpathofapptoremove removed : "$?
	else
	echo "No old version present at $fullpathofapptoremove"
	fi
fi
