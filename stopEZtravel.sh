#!/bin/bash

echo "***Stopping EasyTravel**"

if [ "$(ps aux | grep -i easytravel | wc -l)" != "1" ]; then
  echo stopping easytravel processes
  kill `ps aux | grep -i easytravel | awk '{print $2}'`
else
  echo "No easytravel processes to stop"
fi

CONTAINER=$(sudo docker ps -f name=reverseproxy -q)
if [ "$CONTAINER" != "" ]; then
  echo "removing reverseproxy containter"
  docker stop $CONTAINER
  docker rm $CONTAINER
else
  echo "No containers to stop"
fi

echo "Done."