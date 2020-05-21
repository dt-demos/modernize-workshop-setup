#!/bin/bash

echo ""
echo "=========================================="
echo "Adding Azure monitor for Dynatrace"
echo "Starting: $(date)"
echo "=========================================="

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

AZURE_RESOURCE_GROUP=$(cat $CREDS_FILE | jq -r '.AZURE_RESOURCE_GROUP')
AZURE_SUBSCRIPTION=$(cat $CREDS_FILE | jq -r '.AZURE_SUBSCRIPTION')

SUBSCRIPTION_FILE="azure-sp.json"
SP_NAME="$AZURE_RESOURCE_GROUP-sp" 
CONFIG_FILE=azure-credentials.json

echo "Seeing if $SP_NAME exists"
ID=$(az ad sp list --query [] --filter "displayname eq '$SP_NAME'" --query [].appId -o tsv)
if ! [ -z "$ID" ]; then
    echo "Deleting existing $SP_NAME"
    az ad sp delete --id $ID
else
    echo "$SP_NAME did not exist"
fi

#--scopes /subscriptions/$AZURE_SUBSCRIPTION/subscriptions/YourSubscriptionID2
echo "Adding $SP_NAME"
az ad sp create-for-rbac \
    --name "http://$SP_NAME" \
    --role reader \
    > "$SUBSCRIPTION_FILE"

SP_TENTANT=$(cat $SUBSCRIPTION_FILE | jq -r '.tenant')
SP_APP_ID=$(cat $SUBSCRIPTION_FILE | jq -r '.appId')
SP_PASSWORD=$(cat $SUBSCRIPTION_FILE | jq -r '.password')

cat ./dynatrace/$CONFIG_FILE | \
    sed 's~appId.*~'appId"\": \"$SP_APP_ID"\",'~' | \
    sed 's~directoryId.*~'directoryId"\": \"$SP_TENTANT"\",'~' | \
    sed 's~key.*~'key"\": \"$SP_PASSWORD"\",'~' > ./dynatrace/gen/$CONFIG_FILE

echo ""
echo "============================================="
echo "Adding Azure monitor for Dynatrace COMPLETE"
echo "End: $(date)"
echo "============================================="
echo ""