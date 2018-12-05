#!/bin/bash

#
# SYNOPSIS - How to use
#	Run via a policy to set search domains for all adapters.
#
# DESCRIPTION
#
# 	Populate script parameters to match the variables below.
#   Pass in values into these parameters during a policy.
#   Airprint needs to be enabled on the printer for this to work
#

# Set to the default BASH limiters
IFS=$' \t\n'

# Manually specify the DNS entries (separated by space) to be added to each Ethernet port below, add/remove as needed
# Manually specify the ports to ignore such as Bluetooth, FireWire, etc.
#
DNS="mycompany.com mycompany.org"	#Add your own DNS Searches here on this line#
NoModList="Bluetooth FireWire"
NoModList_Pattern=$( echo $NoModList | sed 's/ /|/g' )

# Set the delimiter to a newline and NOT a space to keep port names whole
# Find the identities of the 'en' ports we wish to edit DNS info, filter out the No Mods to be ignored
IFS=$'\n'
PortList=$(networksetup -listallhardwareports | grep "Device: en" -B 2 | grep "Hardware Port:" | cut -c 16-100 | egrep -v -e $NoModList_Pattern)

# Now, for each port listed in PortList, add the DNS entries
# If an error presents during a config set (missing adapters), don't report the error, 1>/dev/null
for i in $PortList ; do
	echo "taking action for port ": $i
	IFS=$' \t\n'
	networksetup -setsearchdomains "$i" ""$DNS"" 1>/dev/null
done

# Echo out that we're finished adding the DNS entries to the found ports
echo "Done!  The discovered Ethernet ports "$PortList", have been modified"
