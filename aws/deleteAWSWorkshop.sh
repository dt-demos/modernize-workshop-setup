#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

delete_host()
{
  HOSTNAME=$1
  INSTANCE_ID="$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}')"
  if ! [ -z "$INSTANCE_ID" ]; then
    echo "Deleting $HOSTNAME ($INSTANCE_ID)"
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
  else
    echo "Skipping delete $HOSTNAME"
  fi
}

delete_security_group()
{
  GROUP_NAME=$1
  # TODO add this check
  #INSTANCE_ID="$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}')"
  #if ! [ -z "$INSTANCE_ID" ]; then
    echo "Deleting $GROUP_NAME ($INSTANCE_ID)"
    aws ec2 delete-security-group --group-name $GROUP_NAME
  #else
  #  echo "Skipping delete $GROUP_NAME"
  #fi
}

delete_keypair()
{
  KEYPAIR_NAME=$1
  # TODO add this check
  #INSTANCE_ID="$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}')"
  #if ! [ -z "$INSTANCE_ID" ]; then
    echo "Deleting $KEYPAIR_NAME ($INSTANCE_ID)"
    aws ec2 delete-key-pair --key-name $KEYPAIR_NAME
  #else
  #  echo "Skipping delete $KEYPAIR_NAME"
  #fi
}

delete_policy()
{
  echo ""
  #TODO -- needs to use ARN not the NAME 
  #POLICY_NAME=dynatrace-modernize-workshop
  #echo "Deleting iam policy named $POLICY_NAME"
  #aws iam delete-policy --policy-arn <value>
}

#*********************************

AWS_PROFILE=$(cat creds.json | jq -r '.AWS_PROFILE')
AWS_REGION=$(cat creds.json | jq -r '.AWS_REGION')
AWS_KEYPAIR_NAME=$(cat creds.json | jq -r '.AWS_KEYPAIR_NAME')
RESOURCE_PREFIX=$(cat creds.json | jq -r '.RESOURCE_PREFIX')

echo "==================================================================================="
echo "Cleaning Up AWS workshop resources"
echo "Starting: $(date)"
echo "==================================================================================="

delete_host workshop-ez-1
delete_host workshop-ez-docker-1
delete_host workshop-active-gate-1

echo "Sleeping 60 seconds"
sleep 60

delete_security_group security_group_workshop-ez
delete_security_group security_group_workshop-ez-docker

delete_keypair $AWS_KEYPAIR_NAME

echo ""
echo "==================================================================================="
echo "Cleaning Up AWS workshop resources"
echo "End: $(date)"
echo "============================================="
echo ""
