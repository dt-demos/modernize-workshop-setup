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

STACK_NAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop"

delete_keypair()
{
  KEYPAIR_NAME=$1
  echo ""
  echo "-----------------------------------------------------------------------------------"
  echo "Checking to see if $KEYPAIR_NAME exists"
  echo "-----------------------------------------------------------------------------------"

  # delete the keypair needed for ec2 if it exists
  AWS_KEYPAIR_NAME=$(cat creds.json | jq -r '.AWS_KEYPAIR_NAME')
  KEY=$(aws ec2 describe-key-pairs \
    --profile $AWS_PROFILE \
    --region $AWS_REGION | grep $AWS_KEYPAIR_NAME)
  if [ -z "$KEY" ]; then
    echo "Deleting $KEYPAIR_NAME ($INSTANCE_ID)"
    aws ec2 delete-key-pair \
      --key-name $KEYPAIR_NAME \
      --profile $AWS_PROFILE \
      --region $AWS_REGION
  else
    echo ""
    echo "Skipping, delete key-pair $KEYPAIR_NAME since it does not exists"
  fi
}

delete_stack()
{
  echo ""
  echo "-----------------------------------------------------------------------------------"
  echo "Reqesting CloudFormation Delete Stack $STACK_NAME"
  echo "-----------------------------------------------------------------------------------"

  aws cloudformation delete-stack \
      --stack-name $STACK_NAME \
      --profile $AWS_PROFILE \
      --region $AWS_REGION

  echo ""
  echo "Monitor CloudFormation stack status @ https://console.aws.amazon.com/cloudformation/home"
  echo ""
}

#*********************************
echo "==================================================================================="
echo "Cleaning Up AWS workshop resources"
echo "Starting: $(date)"
echo "==================================================================================="

delete_keypair $AWS_KEYPAIR_NAME
delete_stack

echo "==================================================================================="
echo "Cleaning Up AWS workshop resources COMPLETE"
echo "End: $(date)"
echo "============================================="
