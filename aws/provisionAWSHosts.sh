#!/bin/bash

#*********************************
NUM_HOSTS=1
USERDATA_FILE=user_data.tmp

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

EZ_TRAVEL_AMI=$(cat $CREDS_FILE | jq -r '.EZ_TRAVEL_AMI')
AWS_PROFILE=$(cat $CREDS_FILE | jq -r '.AWS_PROFILE')
AWS_REGION=$(cat $CREDS_FILE | jq -r '.AWS_REGION')
AWS_KEYPAIR_NAME=$(cat $CREDS_FILE | jq -r '.AWS_KEYPAIR_NAME')
DT_BASEURL=$(cat $CREDS_FILE | jq -r '.DT_BASEURL')
DT_PAAS_TOKEN=$(cat $CREDS_FILE | jq -r '.DT_PAAS_TOKEN')

#*********************************

=1
while [ $HOST_CTR -le $NUM_HOSTS ]
do

  echo "Provisioning host: $HOST_CTR of $NUM_HOSTS"
  echo ""
  
  #set correct user data in file
  cat user_data.template | \
    sed 's~REPLACE_HOST_GROUP~'"$HOST_CTR"'~' | \
    sed 's~REPLACE_URL~'"$DT_BASEURL"'~' | \
    sed 's~REPLACE_TOKEN~'"$DT_PAAS_TOKEN"'~' > $USERDATA_FILE
  
  INSTANCE_ID=($(aws ec2 run-instances --image-id $EZ_TRAVEL_AMI --count 1 --instance-type t2.medium \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ScaleDemo'$HOST_CTR'}]' 'ResourceType=volume,Tags=[{Key=Name,Value=ScaleDemo'$HOST_CTR'}]' \
  --instance-initiated-shutdown-behavior terminate \
  --key-name $AWS_KEYPAIR_NAME \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  --user-data file://$USERDATA_FILE | jq -r '.Instances | .[].InstanceId'))

  echo "Provisioned host: $HOST_CTR InstanceId: $INSTANCE_ID"

  HOST_CTR=$(( $HOST_CTR + 1 ))

done

rm -rf $USERDATA_FILE

echo "Done."
