#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

export DT_BASEURL=$(cat $CREDS_FILE | jq -r '.DT_BASEURL')
export DT_API_TOKEN=$(cat $CREDS_FILE | jq -r '.DT_API_TOKEN')

# generic add function
add() {

  CONFIG_API_NAME=$1
  CONFIG_NAME=$2
  CONFIG_FILE=$3

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
    | jq -r '.values[] | select(.name == "'$CONFIG_NAME'") | .id')

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
  curl -X POST \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    -d @$CONFIG_FILE
  echo ""
}

# this function used to create the JSON files
# be sure to delete the 'metadata' and 'id' before using it in the add
get() {

  CONFIG_API_NAME=$1
  CONFIG_NAME=$2

  echo "==================================================================================="
  echo "Getting $CONFIG_API_NAME $CONFIG_NAME"

  DT_ID=$(curl -s -X GET \
    "$DT_BASEURL/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'$CONFIG_NAME'") | .id')

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
########################################

echo ""
echo "*** Setting up Dynatrace config for $DT_BASEURL ***"
echo
#get autoTags workshop-group
#get "service/customServices/java" CheckDestination
#add autoTags workshop-group autoTags-workshop-group.json
setFrequentIssueDetectionOff
echo ""
echo "*** Done Setting up Dynatrace config ***"
echo ""