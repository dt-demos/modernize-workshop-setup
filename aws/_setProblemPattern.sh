#!/bin/bash

PROBLEM_PATTERN=$1
ENABLED=$2

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

AWS_PROFILE=$(cat $CREDS_FILE | jq -r '.AWS_PROFILE')
AWS_REGION=$(cat $CREDS_FILE | jq -r '.AWS_REGION')
RESOURCE_PREFIX=$(cat $CREDS_FILE | jq -r '.RESOURCE_PREFIX')
HOSTNAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop-ez-monolith"

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

PUBLIC_IP="$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  | jq -r '.Reservations[0].Instances[0].PublicIpAddress' )"
    
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
