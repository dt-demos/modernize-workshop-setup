#!/bin/bash

PROBLEM_PATTERN=$1
ENABLED=$2

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

AZURE_RESOURCE_GROUP=$(cat $CREDS_FILE | jq -r '.AZURE_RESOURCE_GROUP')
AZURE_SUBSCRIPTION=$(cat $CREDS_FILE | jq -r '.AZURE_SUBSCRIPTION')
AZURE_LOCATION=$(cat $CREDS_FILE | jq -r '.AZURE_LOCATION')
RESOURCE_PREFIX=$(cat $CREDS_FILE | jq -r '.RESOURCE_PREFIX')
HOSTNAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop-ez"

if [ -z $ENABLED ]; then
  ENABLED=true
fi

if [[ "$ENABLED" != "true" && "$ENABLED" != "false" ]]; then
   echo "ERROR: invalid ENABLED argument. Must pass 'true' or 'false'"
   exit 1
fi

if [ -z "$PROBLEM_PATTERN" ]; then
   echo "ERROR: missing PROBLEM_PATTERN argument"
   exit 1
fi

PUBLIC_IP=$(az vm list \
  --location "$AZURE_LOCATION" \
  --name "$AZURE_RESOURCE_GROUP" \
  --subscription "$AZURE_SUBSCRIPTION" \
  --query "[?name=='$HOSTNAME'].publicIps" -d -o tsv)

echo ""
echo "--------------------------------------------------------------------------------------"
echo "Setting $PROBLEM_PATTERN on $HOSTNAME ($PUBLIC_IP)"
STATUS_CODE=$(curl --write-out %{http_code} --silent --output /dev/null "http://$PUBLIC_IP:8091/services/ConfigurationService/setPluginEnabled?name=$PROBLEM_PATTERN&enabled=$ENABLED")
if [[ "$STATUS_CODE" -ne 202 ]] ; then
  echo "ERROR: Received STATUS_CODE = $STATUS_CODE"
  exit 1
else
  echo "Done. Value set to $ENABLED."
fi