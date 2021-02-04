#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "ERROR: script must be run as root or with sudo"
   exit 1
fi

UNIX_USER_HOME_PATH=/home/workshop

echo "*** Stopping EasyTravel Docker ***"
sudo docker-compose -f "$UNIX_USER_HOME_PATH/modernize-workshop-setup/docker-compose.yaml" down

echo "*** Stopping EasyTravel Docker Done. ***"