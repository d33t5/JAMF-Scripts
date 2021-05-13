#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to install driverless printer.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#   Airprint needs to be enabled on the printer for this to work
#

nameofprinter=""
fqdnofprinter=""
location=""

[ "$4" != "" ] && [ "$nameofprinter" == "" ] && nameofprinter=$4
[ "$5" != "" ] && [ "$fqdnofprinter" == "" ] && fqdnofprinter=$5
[ "$6" != "" ] && [ "$location" == "" ] && location=$6

installedprinter=`lpstat -a | grep $nameofprinter`

echo "Printer Name = $nameofprinter"
echo "FQDN Name = $fqdnofprinter"
echo "Location = $location"
echo "Looking for printer to remove..."

if [ "$installedprinter" != "" ];then
	echo "Found printer named $nameofprinter. Removing..."
	/usr/sbin/lpadmin -x "$nameofprinter"
	echo "$nameofprinter removed."
	else
	echo "No printer installed with name $nameofprinter"
	echo "Continuing..."
fi

echo "Setting up printer $nameofprinter..."

/usr/sbin/lpadmin -p "$nameofprinter" \
-L "$location" \
-D "$nameofprinter" \
-E -v ipp://$fqdnofprinter/ipp/print \
-m everywhere \
-o printer-is-shared=false
