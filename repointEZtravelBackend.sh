#!/bin/bash

BACKEND=$1
UNIX_USER_HOME_PATH=/home/workshop

# default the backend name
if [ -z "$BACKEND" ]; then
    echo "ERROR: BACKEND is required argument.  Pass in IP or 'localhost'"
    exit 1
fi

echo "*** Starting EZ Travel Backend Repoint for $BACKEND ***"

#echo "easyTravelConfig.properties BEFORE"
#grep config.backendHost $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties

# change the setting
sed -i 's/config.backendHost=.*/config.backendHost='"$BACKEND"'/g' $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties

#echo "easyTravelConfig.properties AFTER"
#grep config.backendHost $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/resources/easyTravelConfig.properties

# restart ez travel
sudo $UNIX_USER_HOME_PATH/modernize-workshop-setup/startEZtravel.sh
