#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
curl -sS https://raw.githubusercontent.com/seliparjp/xiomiWRT/main/ocean.sh | bash -
