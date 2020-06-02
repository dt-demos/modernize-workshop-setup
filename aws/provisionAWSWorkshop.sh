#!/bin/bash

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

load_dynatrace_config()
{
  # workshop config like tags, dashboard, MZ
  # doing this change directory business, so that can share script across AWS and Azure
  cp creds.json ../dynatrace/creds.json
  cd ../dynatrace
  ./loadDynatraceConfig.sh
  cd ../aws
}

add_aws_keypair()
{
  # add the keypair needed for ec2
  AWS_KEYPAIR_NAME=$(cat creds.json | jq -r '.AWS_KEYPAIR_NAME')
  aws ec2 describe-key-pairs --key-names "$AWS_KEYPAIR_NAME" --output text --query 'KeyPairs[*].[KeyName]' > /dev/null
  if [ $? == 0 ] ; then
    echo "Skipping, key-pair $AWS_KEYPAIR_NAME exists"
  else
    echo "Creating a keypair named $AWS_KEYPAIR_NAME for the ec2 instances"
    echo "Saving output to $AWS_KEYPAIR_NAME-keypair.json"
    aws ec2 create-key-pair --key-name $AWS_KEYPAIR_NAME --query 'KeyMaterial' --output text > $AWS_KEYPAIR_NAME-keypair.pem
  fi
}

# not used yet
add_aws_policy()
{
  POLICY_NAME=dynatrace-modernize-workshop
  echo "Creating iam policy named $POLICY_NAME"
  aws iam create-policy --policy-name $POLICY_NAME --policy-document file://aws_monitor_policy.json
}

############################################################
# add active-gate VM
#./createHosts.sh active-gate

echo ""
echo "=========================================="
echo "Provisioning AWS workshop resources"
echo "Starting: $(date)"
echo "=========================================="

load_dynatrace_config
add_aws_keypair

# add VMs with easyTravel
./createHosts.sh ez
./createHosts.sh ez-docker

echo ""
echo "============================================="
echo "Provisioning AWS workshop resources COMPLETE"
echo "End: $(date)"
echo "============================================="
echo ""
echo "Monitor ec2 status @ https://console.aws.amazon.com/ec2/v2/home"