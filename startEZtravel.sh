#!/bin/bash

LOGFILE='/tmp/EZtravel.log'
UNIX_USER_HOME_PATH=/home/root

echo "*** Calling Stop EasyTravel ***"
sudo ./stopEZtravel.sh

echo "*** Starting EasyTravel ***"
printf "\n\n***** Init Log ***\n" > $LOGFILE 2>&1
{ date ; apt update 2>/dev/null; whoami ; } >> $LOGFILE ; chmod 777 $LOGFILE

echo "*** Starting reverse proxy ***"
docker run -p 80:80 -v $UNIX_USER_HOME_PATH/nginx:/etc/nginx/conf.d/:ro -d --name reverseproxy nginx:1.15

echo "*** Start eztravel ***"
su -c "sh $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/weblauncher/weblauncher.sh > /tmp/weblauncher.log 2>&1 &"
{ [[ -f /tmp/weblauncher.log ]] && echo "*** EasyTravel launched ***" || echo "*** Problem launching EasyTravel ***" ; } >> $LOGFILE 2>&1

echo "*** Done ***"
echo "View log with: tail -f /tmp/weblauncher.log"