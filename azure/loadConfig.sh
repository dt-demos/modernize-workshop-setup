#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

export DT_BASEURL=$(cat $CREDS_FILE | jq -r '.DT_BASEURL')
export DT_API_TOKEN=$(cat $CREDS_FILE | jq -r '.DT_API_TOKEN')

# generic add function
addConfig() {

  CONFIG_API_NAME=$1
  CONFIG_NAME=$2
  CONFIG_FILE=$3

  # hack for when developing scripts
  if [ "1" == "2" ]; then
    DT_ID=APPLICATION-552F47836A297E61
    curl -X DELETE "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME/$DT_ID?Api-Token=$DT_API_TOKEN" -H 'Content-Type: application/json' -H 'cache-control: no-cache'
    curl -s -X GET "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" -H 'Content-Type: application/json' -H 'cache-control: no-cache' | jq -r '.values[]'
    exit
  fi

  if ! [ -f "$CONFIG_FILE" ]; then
    echo "==================================================================================="
    echo "SKIPPING $CONFIG_API_NAME $CONFIG_NAME"
    echo "Missing $CONFIG_FILE file"
    exit
  fi

  echo "==================================================================================="
  echo "Checking if $CONFIG_API_NAME $CONFIG_NAME exists"

  DT_ID=$(curl -s -X GET \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'${CONFIG_NAME}'") | .id')

  # if exists, then delete it
  if [ "$DT_ID" != "" ]
  then
    echo "Deleting $CONFIG_API_NAME $CONFIG_NAME (ID = $DT_ID)"
    curl -X DELETE \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME/$DT_ID?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache'
    
    echo "Waiting 10 seconds to ensure $CONFIG_NAME is deleted"
    sleep 10
  else
    echo "$CONFIG_API_NAME $CONFIG_NAME does not exist"
  fi

  echo "Adding $CONFIG_API_NAME $CONFIG_NAME"
  DT_ID=$(curl -s -X POST \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d @$CONFIG_FILE \
    | jq -r '.id')
  echo "Created $CONFIG_NAME (ID=$DT_ID)"

  if [ "$CONFIG_NAME" == "EasyTravelAngular" ]; then
    echo "Waiting 30 seconds to ensure $CONFIG_NAME exists"
    sleep 30
    echo "Adding applicationDetectionRules for $CONFIG_NAME (ID=$DT_ID)"
    addApplicationRule $DT_ID app1-rule1.json
    addApplicationRule $DT_ID app1-rule2.json
    addApplicationRule $DT_ID app1-rule3.json
    addApplicationRule $DT_ID app1-rule4.json
    echo ""
  fi
  if [ "$CONFIG_NAME" == "EasyTravelOrange" ]; then
    echo "Waiting 30 seconds to ensure $CONFIG_NAME exists"
    sleep 30
    echo "Adding applicationDetectionRules for $CONFIG_NAME (ID=$ID)"
    addApplicationRule $DT_ID app2-rule1.json
    addApplicationRule $DT_ID app2-rule2.json
    echo ""
  fi
}

# this function used to create the JSON files
# be sure to delete the 'metadata' and 'id' before using it in the add
getConfig() {

  CONFIG_API_NAME=${1}
  CONFIG_NAME=${2}

  echo "==================================================================================="
  echo "Getting $CONFIG_API_NAME $CONFIG_NAME"

  DT_ID=$(curl -s -X GET \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'${CONFIG_NAME}'") | .id')

  # if exists, then get it
  if [ "$DT_ID" != "" ]
  then
    curl -s -X GET \
        "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME/$DT_ID?Api-Token=$DT_API_TOKEN" \
        -H 'Content-Type: application/json' \
        -H 'cache-control: no-cache'  \
        | jq -r '.'
  else
    echo "$CONFIG_API_NAME $CONFIG_NAME does not exist"
  fi
}

addApplicationRule() {

  ID=$1
  CONFIG_FILE=$2

  CONFIG_API_NAME="applicationDetectionRules"
  echo ""
  echo "Adding applicationDetectionRules $CONFIG_FILE to ID=$ID"

  cat ./dynatrace/$CONFIG_FILE | \
    sed 's~applicationIdentifier.*~'applicationIdentifier"\": \"$ID"\",'~' > ./dynatrace/gen/$CONFIG_FILE

  curl -s -X POST \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d @./dynatrace/gen/$CONFIG_FILE
}

# load application get ID then use that ID in the appRule files
# docker - webrequest contains easytravel
# nondocker - webrequet contains cloudapp

setFrequentIssueDetectionOff() {
  ENABLED=$1

  echo "==================================================================================="
  echo "Setting FrequentIssueDetection off"

  curl -L -X PUT \
    "$DT_BASEURL/api/config/v1/frequentIssueDetection?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    --data-raw '{
        "frequentIssueDetectionApplicationEnabled": false,
        "frequentIssueDetectionServiceEnabled": false,
        "frequentIssueDetectionInfrastructureEnabled": false
    }'
}

########################################
# Example values for CONFIG_API_NAME 
# managementZones
# service/requestAttributes
# autoTags
# alertingProfiles
#---
#getConfig autoTags workshop-group
#getConfig "service/customServices/java" CheckDestination
########################################

echo ""
echo "*** Setting up Dynatrace config for $DT_BASEURL ***"
echo

setFrequentIssueDetectionOff

addConfig autoTags workshop-group ./dynatrace/autoTags-workshop-group.json

addConfig "applications/web" EasyTravelAngular ./dynatrace/application-1.json
addConfig "applications/web" EasyTravelOrange ./dynatrace/application-2.json

#addConfig dashboards EasyTravel ./dynatrace/db.json

echo ""
echo "*** Done Setting up Dynatrace config ***"
echo ""