#!/bin/bash

source ./dynatraceConfig.lib

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

source ../dynatrace/dynatraceConfig.lib

AZURE_RESOURCE_GROUP=$(cat $CREDS_FILE | jq -r '.AZURE_RESOURCE_GROUP')
AZURE_SUBSCRIPTION=$(cat $CREDS_FILE | jq -r '.AZURE_SUBSCRIPTION')
AZURE_LOCATION=$(cat $CREDS_FILE | jq -r '.AZURE_LOCATION')

SUBSCRIPTION_FILE="azure-sp.json"
SP_NAME="$AZURE_RESOURCE_GROUP-sp" 
CONFIG_FILE=azure-credentials.json

#*********************************
create_resource_group()
{
  # only create if it does not exist
  if [ -z $(az group show -n $AZURE_RESOURCE_GROUP --subscription $AZURE_SUBSCRIPTION --query id) ]; then
    echo "Creating resource group: $AZURE_RESOURCE_GROUP"
    az group create \
      --location "$AZURE_LOCATION" \
      --name "$AZURE_RESOURCE_GROUP" \
      --subscription "$AZURE_SUBSCRIPTION"
  else
    echo "Using resource group $AZURE_RESOURCE_GROUP"
  fi
}

# create_resource_group

echo "Seeing if $SP_NAME exists in Azure"
ID=$(az ad sp list --query [] --filter "displayname eq '$SP_NAME'" --query [].appId -o tsv)
if ! [ -z "$ID" ]; then
    echo "Deleting existing $SP_NAME within Azure"
    az ad sp delete --id $ID
else
    echo "$SP_NAME did not exist in Azure"
fi

#--scopes /subscriptions/$AZURE_SUBSCRIPTION/subscriptions/YourSubscriptionID2
echo "Adding $SP_NAME to Azure"
az ad sp create-for-rbac \
    --name "http://$SP_NAME" \
    --role reader \
    > "$SUBSCRIPTION_FILE"

echo "Sleeping 10 seconds to allow for Azure subscription creation"
sleep 10

echo "Reading values from $SUBSCRIPTION_FILE file"
SP_TENTANT=$(cat $SUBSCRIPTION_FILE | jq -r '.tenant')
SP_APP_ID=$(cat $SUBSCRIPTION_FILE | jq -r '.appId')
SP_PASSWORD=$(cat $SUBSCRIPTION_FILE | jq -r '.password')

echo "Generating ../dynatrace/dynatrace/gen/$CONFIG_FILE file"
cat ../dynatrace/dynatrace/$CONFIG_FILE | \
    sed 's|appId.*|'appId"\": \"$SP_APP_ID"\",'|' | \
    sed 's|directoryId.*|'directoryId"\": \"$SP_TENTANT"\",'|' | \
    sed 's|key.*|'key"\": \"$SP_PASSWORD"\",'|' > ../dynatrace/dynatrace/gen/$CONFIG_FILE

echo "Adding Dynatrace config needed for Azure monitor"
addConfig "azure/credentials" azure-modernize-workshop ../dynatrace/dynatrace/gen/azure-credentials.json

echo ""
echo "============================================="
echo "Adding Azure monitor for Dynatrace COMPLETE"
echo "End: $(date)"
echo "============================================="
echo ""