#!/bin/bash

LOGFILE='/tmp/EZtravel.log'
UNIX_USER_HOME_PATH=/home/workshop

echo "*** Calling Stop EasyTravel ***"
sudo ./$UNIX_USER_HOME_PATH/stopEZtravel.sh

echo "*** Starting EasyTravel ***"
printf "\n\n***** Init Log ***\n" > $LOGFILE 2>&1
{ date ; apt update 2>/dev/null; whoami ; } >> $LOGFILE ; chmod 777 $LOGFILE

echo "*** Starting reverse proxy ***"
docker run -p 80:80 -v $UNIX_USER_HOME_PATH/nginx:/etc/nginx/conf.d/:ro -d --name reverseproxy nginx:1.15

echo "*** Start eztravel as workshop user ***"
{ [[ -f /tmp/weblauncher.log ]] && echo "*** EasyTravel launched ***" || echo "*** Problem launching EasyTravel ***" ; } >> $LOGFILE 2>&1

echo "*** Done ***"
echo "View log with: tail -f /tmp/weblauncher.log"