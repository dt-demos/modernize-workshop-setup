#!/bin/bash

echo ""
echo ""
PRIVATE_IP=`hostname -i | awk '{ print $1'}`
if [ "$(curl -s http://$PRIVATE_IP:28018/services/ConfigurationService/ping | grep pong | wc -l)" == "1" ]; then
  echo "Backend is running"
else
  echo "Backend not responding"
fi

exit
if [ "$(docker ps -a -q)" != "" ]; then
  echo "*** Stopping and removing all Docker containers ***"
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
fi

echo "*** Starting Mongo Docker container ***"

docker run -d --name mongodb \
    -p 27017:27017 -p 28018:28018 \
    dynatrace/easytravel-mongodb

echo "*** Starting Backend Docker container ***"

PRIVATE_IP=`hostname -i | awk '{ print $1'}`

docker run -p 8091:8091 -d --name backend \
    -e CATALINA_OPTS="-Dconfig.apmServerDefault=${ET_APM_SERVER_DEFAULT} -Xmx300m" \
    -e ET_DATABASE_LOCATION="$PRIVATE_IP:27017" \
    dynatrace/easytravel-backend

echo "*** Running containers ***"
echo ""

docker ps

echo ""
echo ""
if [ "$(curl -s http://$PRIVATE_IP:28018/services/ConfigurationService/ping | grep pong | wc -l)" == "1" ]; then
  echo "Backend is running"
else
  echo "Backend not responding"
fi

echo "*** Done. ***"
