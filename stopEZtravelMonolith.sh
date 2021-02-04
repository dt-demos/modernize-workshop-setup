#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "ERROR: script must be run as root or with sudo"
   exit 1
fi

echo "*** Stopping EasyTravel Docker ***"

sudo docker-compose down

echo "*** Stopping EasyTravel Docker Done. ***"