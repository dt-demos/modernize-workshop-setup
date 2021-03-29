#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

AZURE_RESOURCE_GROUP=$(cat $CREDS_FILE | jq -r '.AZURE_RESOURCE_GROUP')
AZURE_SUBSCRIPTION=$(cat $CREDS_FILE | jq -r '.AZURE_SUBSCRIPTION')

HOSTNAME_MONOLITH="workshop-ez-monolith-1"
PUBLIC_IP_MONOLITH=$(az vm list \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --subscription "$AZURE_SUBSCRIPTION" \
  --query "[?name=='$HOSTNAME_MONOLITH'].publicIps" -d -o tsv)

HOSTNAME_DOCKER="workshop-ez-docker-1"
PUBLIC_IP_DOCKER=$(az vm list \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --subscription "$AZURE_SUBSCRIPTION" \
  --query "[?name=='$HOSTNAME_DOCKER'].publicIps" -d -o tsv)

echo ""
echo ""
echo "-----------------------------------------------------------------------------------"
echo "Website URLs:"
echo "-----------------------------------------------------------------------------------"
echo ""
echo "MONOLITH"
echo "http://$PUBLIC_IP_MONOLITH"
echo ""
echo "DOCKER"
echo "http://$PUBLIC_IP_DOCKER"
echo ""
echo ""