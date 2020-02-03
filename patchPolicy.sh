#!/bin/bash

# Create or update patch defintions
# Requires https://github.com/brysontyrrell/Patch-Starter-Script placed into a dir called 'py'
# Will default to set minimum OS version to 10.9

patchStarterDir="py"

########################################################################################
## script functions
########################################################################################

createPatchPolicy()
{
    curl https://beta2.communitypatch.com/api/v1/titles \
    -X POST \
    -d "$(python "$patchStarterDir"/patchstarter.py "${applicationPath%/}"/"${applicationName%.*}".app -p "$publisherName" --min-sys-version "10.9")" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $apiToken"
}

updatePatchPolicy()
{
    curl https://beta2.communitypatch.com/api/v1/titles/$appID/versions \
    -X POST \
    -d "$(python "$patchStarterDir"/patchstarter.py "${applicationPath%/}"/"${applicationName%.*}".app --patch-only)" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $apiToken"
}

###############################################
## Check for patchstarter.py
###############################################

while [ ! -f "$patchStarterDir"/patchstarter.py ]; do
    echo "patchstarter.py not found at default dir"
    while true; do
        read -rp "Do you want to enter path to patchstarter.py? [Y/n] :" yn
        case ${yn} in
            [Yy]* ) read -p "Enter path : " pyPathEntered
                    patchStarterDir="${pyPathEntered%/patchstarter.py}"
                    break;;
            [Nn]* ) exit 0;;
            * ) read -p "Enter path : " pyPathEntered
                patchStarterDir="${pyPathEntered%/patchstarter.py}"
                break;;
        esac
    done
    
done

###############################################
## Echo instructions
###############################################

clear
echo "Create Or Update Patch Definitions"
echo "Instructions"
echo "1. Install app on the computer running this script"
echo "2. Enter the name of the app, e.g. VMware Fusion.app"
echo "3. Set the path of the application"
echo "   default is /Applications/"
echo "4. Choose if you are creating a new patch policy"
echo "   default is to update an existing policy"
echo "5. For a new policy you will be asked to enter a publisher"
echo "6. Enter API token"
echo ""

###############################################
## Get patch info from operator
###############################################

read -p "Enter the application name : " appNameEntered
applicationName=${appNameEntered%.*}

while true; do
    read -rp "Is the application located in /Applications? [Y/n] :" yn
    case ${yn} in
        [Yy]* ) applicationPath='/Applications' break;;
        [Nn]* ) read -p "Enter the application path : " appPathEntered
                applicationPath="${appPathEntered%/}"
                break;;
        * ) applicationPath='/Applications' break;;
    esac
done

if [ ! -d "${applicationPath%/}"/"${applicationName%.*}".app ]; then
    echo "No application at path "${applicationPath%/}"/"${applicationName%.*}".app"
    echo "Please ensure you have the correct app name and path and try again"
    exit 0
fi

while true; do
    read -rp "Are you updating a patch definition? [Y/n] :" yn
    case ${yn} in
        [Yy]* ) createPatch=false break;;
        [Nn]* ) read -p "Enter publisher name : " publisherEntered
                publisherName="$publisherEntered"
                createPatch=true
                break;;
        * ) createPatch=false break;;
    esac
done

read -sp "Enter API token : " apiTokenEntered
apiToken="$apiTokenEntered"
echo ""

#Get appID in the same way as patchstarter.py
appName=$(defaults read "${applicationPath%/}"/"${applicationName%.*}".app/Contents/Info.plist CFBundleName)
appID=$(tr -d ' ' <<< "$appName")


if [ $createPatch = "true" ]; then
    createPatchPolicy
    else
    updatePatchPolicy
fi
