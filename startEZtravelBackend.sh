#!/bin/bash

if [ "$(docker ps -a -q)" != "" ]; then
  echo "*** Stopping and removing EZ Travel Backend and Mongo Docker containers ***"
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
fi

echo "*** Starting Mongo Docker container ***"

docker run -d --name mongodb \
    -p 27017:27017 -p 28018:28018 \
    dynatrace/easytravel-mongodb

echo "*** Starting Backend Docker container ***"

PRIVATE_IP=`hostname -i | awk '{ print $1'}`

docker run -p 8091:8080 -d --name backend \
    -e CATALINA_OPTS="-Dconfig.apmServerDefault=${ET_APM_SERVER_DEFAULT} -Xmx300m" \
    -e ET_DATABASE_LOCATION="$PRIVATE_IP:27017" \
    dynatrace/easytravel-backend

echo "*** Running containers ***"
echo ""
docker ps

echo ""
echo "*** Sleeping 10 seconds to allow backend to startup"
sleep 10
echo ""
if [ "$(curl -s http://$PRIVATE_IP:8091/services/ConfigurationService/ping | grep pong | wc -l)" == "1" ]; then
  echo "Backend is running"
else
  echo "ERROR: Backend not responding"
fi

echo "*** Done. ***"