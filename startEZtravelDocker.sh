#!/bin/bash

LOGFILE='/tmp/startEZtravelDocker.log' 
UNIX_USER_HOME_PATH=/home/workshop
START_TIME="$(date)"

printf "\n\n***** Init Log ***\n" > $LOGFILE 2>&1
{ date ; apt update 2>/dev/null; whoami ; } >> $LOGFILE ; sudo chmod 777 $LOGFILE

printf "\n\n***** Deleting /tmp/weblauncher.log ***\n" >> $LOGFILE 2>&1
rm -f /tmp/weblauncher.log

printf "\n\n***** Calling stopEZtravelDocker.sh ***\n" >> $LOGFILE 2>&1
sudo $UNIX_USER_HOME_PATH/modernize-workshop-setup/stopEZtravelDocker.sh

sudo docker-compose -f "$UNIX_USER_HOME_PATH/modernize-workshop-setup/docker-compose.yaml" up -d

END_TIME="$(date)"
printf "\n\n" >> $LOGFILE 2>&1
printf "\n\nSTART_TIME: $START_TIME     END_TIME: $END_TIME" >> $LOGFILE 2>&1

sudo $UNIX_USER_HOME_PATH/modernize-workshop-setup/showEZtravelUrl.sh >> $LOGFILE 2>&1