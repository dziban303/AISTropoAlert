#!/bin/bash

# AISTropoAlert script
# Script to send a Mastodon alert when far away ships are seen
# Copyright 2023 Jeffrey Luszcz
# https://github.com/jeff-luszcz/AISTropoAlert
# SPDX-License-Identifier: Apache License 2.0
# version 1.0.0

# Heavily modified for basic functionality by Dziban Molniya
# https://github.com/dziban303/AISTropoAlert

# This BASH script reads the input from a specific AIS-Catcher web server 
# and checks to see if any reports are further than a user specified distance
# Seeing ships that are farther away than normal may indicate the Tropospheric Ducting
# or other long distance propagation at VHF/UHF frequencies is ongoing
# See https://en.wikipedia.org/wiki/Tropospheric_propagation

# Requirements
# This script requires curl and jq command line tools as wella s AIS-Catcher
# A Mastodon account and token

# User required Actions:
# replace the variable tokens with your data

############################################################
# Replace the following  variables to customize your script

# What is the minimum distance that you wish to send alerts when surpassed
DIST=20

# What is the full URL including port number of your AIS-catcher web server instance 
URL=raspberrypi.local:8100

# what is the posting URL for your Mastodon server e.g. "https://mastodon.social/api/v1/statuses"
MASTODON_URL="https://airwaves.social/api/v1/statuses"

# what is your Mastodon token (this should remain a secret, don't share it anywhere!!!)
MASTODON_TOKEN=replace_this_with_your_mastondon_token

# receiver location
LOC=my_location

############################################################

# get the ist of ships from AIS-Catcher's JSON web api using curl, search the JSON for ships further away than X miles using jq, then sort and find further away ship
SHIPS=$(curl -s $URL/ships.json  | jq --arg dist $DIST '.ships[] | select(.distance>=($dist|tonumber)) | .distance' | sort -nr | head -1)
NOW=$(date)

# if we have any resuts, post an alert to Mastodon, otherwise do nothing
if [ "$SHIPS" ]
then
    echo "Furthest ship seen was $SHIPS nautical miles away further than $DIST nautical miles away. Sending alert to Mastodon at $NOW."
    MESSAGE="Possible Tropo Near $LOC: AIS reports from $SHIPS nautical miles away seen at $NOW. Alerts triggered when ships seen over $DIST nautical miles away."
    curl $MASTODON_URL -H "Authorization: Bearer $MASTODON_TOKEN" -F "status=$MESSAGE"
else
    echo "No topo at $NOW. Not doing anything."
fi