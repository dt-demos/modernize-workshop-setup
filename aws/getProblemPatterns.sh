#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

AWS_PROFILE=$(cat $CREDS_FILE | jq -r '.AWS_PROFILE')
AWS_REGION=$(cat $CREDS_FILE | jq -r '.AWS_REGION')
RESOURCE_PREFIX=$(cat $CREDS_FILE | jq -r '.RESOURCE_PREFIX')

if [ $PUBLIC_IP == "null" ]; then
  HOSTNAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop-ez-monolith"
else
  HOSTNAME=$1
fi

PUBLIC_IP="$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  | jq -r '.Reservations[0].Instances[0].PublicIpAddress' )"

if [ -z $PUBLIC_IP ]; then
  echo "PUBLIC IP not found for $HOSTNAME"
  exit 1
else
  echo ""
  echo "--------------------------------------------------------------------------------------"
  echo "Enabled Patterns on $HOSTNAME ($PUBLIC_IP)"
  echo "--------------------------------------------------------------------------------------"
  curl -s "http://$PUBLIC_IP:8091/services/ConfigurationService/getEnabledPluginNames" | \
    sed -e 's|<ns:getEnabledPluginNamesResponse xmlns:ns=\"http://webservice.business.easytravel.dynatrace.com\">||g' | \
    sed -e 's|</ns:getEnabledPluginNamesResponse>||g' | \
    sed -e 's|</ns:return><ns:return>|\n|g' | \
    sed -e 's|<ns:return>|\n|g' | \
    sed -e 's|</ns:return>|\n|g'
  echo ""
  echo ""
fi