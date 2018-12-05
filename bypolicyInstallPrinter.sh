#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to install printers.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#

ppdlocation="/Library/Printers/PPDs/Contents/Resources"
installedprinter=`lpstat -a | grep $nameofprinter`

# examples
# nameofprinter=Printer1
# fqdnofprinter=printer1.mycompany.com
# ppdname="KONICAMINOLTAC258.gz"
# location="1st Floor"
# protocol="lpd"
# printdriver="konicaprint" (This is the JAMF trigger for the printer driver policy)

nameofprinter=""
fqdnofprinter=""
protocol=""
location=""
ppdname=""
printdriver=""

[ "$4" != "" ] && [ "$nameofprinter" == "" ] && nameofprinter=$4
[ "$5" != "" ] && [ "$fqdnofprinter" == "" ] && fqdnofprinter=$5
[ "$6" != "" ] && [ "$protocol" == "" ] && protocol=$6
[ "$7" != "" ] && [ "$location" == "" ] && location=$7
[ "$8" != "" ] && [ "$ppdname" == "" ] && ppdname=$8
[ "$9" != "" ] && [ "$printdriver" == "" ] && printdriver=$9



########################################################################################
## script start
########################################################################################

echo "Printer Name = $nameofprinter"
echo "FQDN Name = $fqdnofprinter"
echo "Protocol = $protocol"
echo "Location = $location"
echo "Looking for printer to remove..."

if [ "$installedprinter" != "" ];then
	echo "Found printer named $nameofprinter. Removing..."
	lpadmin -x "$nameofprinter"
	echo "$nameofprinter removed."
	else
	echo "No printer installed with name $nameofprinter"
	echo "Continuing..."
fi

echo "Setting printer $nameofprinter..."

if [ "$ppdname" != "" ];then
	echo "PPD specified: $ppdname"
	echo "Ensuring drivers installed for printer: $nameofprinter"
	jamf policy -trigger driver_"$printdriver"
	echo "$printdriver installed."
	else
		echo "No PPD specified, using generic PPD..."
    ppdlocation="/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Resources"
    ppdname="Generic.ppd"
fi

case $protocol in
  airprint)
      echo "Setting printer as $protocol"
      lpadmin -p "$nameofprinter" -L "$location" -D "$nameofprinter" -E -v ipp://$fqdnofprinter/ipp/print -m everywhere -o printer-is-shared=false
			;;
	ipp)
			echo "Setting printer as $protocol"
			lpadmin -p "$nameofprinter" -L "$location" -E -v ipp://$fqdnofprinter/ipp/print -P "$ppdlocation"/"$ppdname" -o printer-is-shared=false
			;;
	lpd)
			echo "Setting printer as $protocol"
      lpadmin -p "$nameofprinter" -L "$location" -E -v lpd://$fqdnofprinter -P "$ppdlocation"/"$ppdname" -o printer-is-shared=false
      ;;
  smb)
			echo "Setting printer as $protocol"
      lpadmin -p "$nameofprinter" -L "$location" -E -v smb://$fqdnofprinter -P "$ppdlocation"/"$ppdname" -o printer-is-shared=false -o auth-info-required=negotiate
      ;;
  *)
      echo "Unknown print protocol"
			echo "Exiting..."
			exit 1
esac

echo "Printer $nameofprinter configured as $protocol."
