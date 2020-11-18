#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

AWS_PROFILE=$(cat creds.json | jq -r '.AWS_PROFILE')
AWS_REGION=$(cat creds.json | jq -r '.AWS_REGION')
AWS_KEYPAIR_NAME=$(cat creds.json | jq -r '.AWS_KEYPAIR_NAME')
RESOURCE_PREFIX=$(cat creds.json | jq -r '.RESOURCE_PREFIX')

echo ""
echo "-----------------------------------------------------------------------------------"
echo "To SSH to EC2 hosts use:"
echo "-----------------------------------------------------------------------------------"

HOSTNAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop-ez-monolith"
PUBLIC_IP="$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  | jq -r '.Reservations[0].Instances[0].PublicIpAddress' )"

echo ""
echo "# $HOSTNAME"
echo "ssh -i \"gen/$AWS_KEYPAIR_NAME-keypair.pem\" ubuntu@$PUBLIC_IP"

HOSTNAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop-ez-docker"
PUBLIC_IP="$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  | jq -r '.Reservations[0].Instances[0].PublicIpAddress' )"

echo ""
echo "-----------------------------------------------------------------------------------"
echo ""
echo "# $HOSTNAME"
echo "ssh -i \"gen/$AWS_KEYPAIR_NAME-keypair.pem\" ubuntu@$PUBLIC_IP"
echo ""
echo ""