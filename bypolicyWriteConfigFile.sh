#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to populate com.arm.buildconfig.plist with values.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#

configFolder="/Library/Application Support/MyCompany"
plistName="com.mycompany.buildconfig.plist"
getDate=$(date "+%Y-%m-%d %H:%M:%S")


valueType=""	#	-int -bool -array -string
keyLabel=""		#	"string"
keyValue=""		#	"string"


[ "$4" != "" ] && [ "$valueType" == "" ] && valueType=$4
[ "$5" != "" ] && [ "$keyLabel" == "" ] && keyLabel=$5
[ "$6" != "" ] && [ "$keyValue" == "" ] && keyValue=$6

# look for configFolder and create it if it doesnt exist

if [ ! -d "$configFolder" ]; then
  mkdir "$configFolder"
  chmod 755 "$configFolder"
fi

# if keyValue variable is passed as date then set it to current date

if [ "$keyValue" = "date" ]; then
  keyValue=$(date "+%Y-%m-%d %H:%M:%S")
fi

# Write to the plist file

defaults write "$configFolder"/"$plistName" "$keyLabel" "$valueType" "$keyValue"

# Modify permissions to be able to easily read file

chmod 755 "$configFolder"/"$plistName"

jamf recon
