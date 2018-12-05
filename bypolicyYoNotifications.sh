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

title=""			#	"string"
information=""		#	"string"
button=""			#	"string"
action=""			#	path


[ "$4" != "" ] && [ "$title" == "" ] && title=$4
[ "$5" != "" ] && [ "$information" == "" ] && information=$5
[ "$6" != "" ] && [ "$button" == "" ] && button=$6
[ "$7" != "" ] && [ "$action" == "" ] && action=$7

/usr/local/bin/yo_scheduler -t "$title" -n "$information" -b "$button" -a "$action"
