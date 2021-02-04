#!/bin/bash

LOGFILE='/tmp/EZtravel.log'
UNIX_USER_HOME_PATH=/home/workshop
START_TIME="$(date)"

echo "*** Calling Stop EasyTravel ***"
sudo $UNIX_USER_HOME_PATH/modernize-workshop-setup/stopEZtravelMonolith.sh

printf "\n\n***** Init Log ***\n" > $LOGFILE 2>&1
{ date ; apt update 2>/dev/null; whoami ; } >> $LOGFILE ; sudo chmod 777 $LOGFILE

printf "\n\n***** Deleting /tmp/weblauncher.log ***\n" >> $LOGFILE 2>&1
sudo rm -f /tmp/weblauncher.log

echo "sleeping 10 seconds to ensure easyTravel is fully down"
sleep 10

echo "*** Starting reverse proxy ***"
docker run -p 80:80 -v $UNIX_USER_HOME_PATH/nginx/classic:/etc/nginx/conf.d/:ro -d --name reverseproxy-classic nginx:1.15
docker run -p 81:80 -v $UNIX_USER_HOME_PATH/nginx/angular:/etc/nginx/conf.d/:ro -d --name reverseproxy-angular nginx:1.15

echo "*** Start eztravel ***"
# if not workshop user, then run as workshop user
# if always use workshop, then get prompted for password
# easyTravel require that is to not run a root user
if [ `whoami` == "workshop" ]; then
    $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/weblauncher/weblauncher.sh > /tmp/weblauncher.log 2>&1 &
else
    echo "*** Starting EasyTravel as workshop user ***"  >> $LOGFILE 2>&1
    su -c "sh $UNIX_USER_HOME_PATH/easytravel-2.0.0-x64/weblauncher/weblauncher.sh > /tmp/weblauncher.log 2>&1 &" workshop
fi
{ [[ -f /tmp/weblauncher.log ]] && echo "*** EasyTravel launched ***" || echo "*** Problem launching EasyTravel ***" ; } >> $LOGFILE 2>&1

while IFS= read -r LOGLINE || [[ -n "$LOGLINE" ]]; do
    printf '%s\n' "$LOGLINE"
    [[ "${LOGLINE}" == *"easyTravel procedures started successfully"* ]] && echo "easyTravel READY" && break
done < <(timeout 100 tail -f /tmp/weblauncher.log)

END_TIME="$(date)"
echo ""
echo "START_TIME: $START_TIME     END_TIME: $END_TIME"

echo ""
echo "View weblauncher log again with: tail -f /tmp/weblauncher.log"
echo ""

sudo $UNIX_USER_HOME_PATH/modernize-workshop-setup/showEZtravelUrl.sh