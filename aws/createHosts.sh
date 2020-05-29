#!/bin/bash

#*********************************
# Reference: 
# Dynatrace: https://www.dynatrace.com/support/help/technology-support/cloud-platforms/microsoft-azure/azure-services/virtual-machines/deploy-oneagent-on-azure-virtual-machines
#*********************************
HOST_TYPE=$1               # example: 'ez'
NUM_HOSTS=$2
ADD_EZTRAVEL_ONEAGENT=$3   # only for eztravel, pass in 'yes' if want agent added

CREDS_FILE=creds.json
if ! [ -f "$CREDS_FILE" ]; then
  echo "ERROR: missing $CREDS_FILE"
  exit 1
fi

if [ -z $2 ]; then
  NUM_HOSTS=1
fi

DT_ENVIRONMENT_ID=$(cat $CREDS_FILE | jq -r '.DT_ENVIRONMENT_ID')
DT_BASEURL=$(cat $CREDS_FILE | jq -r '.DT_BASEURL')
DT_PAAS_TOKEN=$(cat $CREDS_FILE | jq -r '.DT_PAAS_TOKEN')
DT_API_TOKEN=$(cat $CREDS_FILE | jq -r '.DT_API_TOKEN')
AWS_PROFILE=$(cat creds.json | jq -r '.AWS_PROFILE')
AWS_REGION=$(cat creds.json | jq -r '.AWS_REGION')
AWS_KEYPAIR_NAME=$(cat creds.json | jq -r '.AWS_KEYPAIR_NAME')
RESOURCE_PREFIX=$(cat creds.json | jq -r '.RESOURCE_PREFIX')

#*********************************
does_vm_exist()
{
  INSTANCE_ID="$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$HOSTNAME" --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}')"
  if [[ -z "$INSTANCE_ID" ]]; then
    echo false
  else
    echo true
  fi
}

#*********************************
does_security_group_exist()
{
  GROUPNAME="$(aws ec2 describe-security-groups --group-name "$SECURITY_GROUP" --output text --query 'SecurityGroups[*].[GroupName]')"
  if [[ -z "$GROUPNAME" ]]; then
    echo false
  else
    echo true
  fi
}

#*********************************
provision_linux_active_gate()
{
  HOSTGROUP=$1
  HOSTNAME="workshop-active-gate-$HOSTGROUP"

  echo "Checking if VM $HOSTNAME already exists"
  CHECK="$(does_vm_exist)"
  if [ "$CHECK" == "true" ]; then
    echo "Skipping, host $HOSTNAME exists"
    echo ""
  else
    echo "Adding $HOSTNAME"
    echo ""
      
    # make user data file DT API and TOKEN info
    USERDATA_FILE="user_data_active_gate.gen"

    echo "#cloud-config" > $USERDATA_FILE
    echo "runcmd:" >> $USERDATA_FILE
    echo "  - wget -O /tmp/Dynatrace-ActiveGate-Linux-x86-1.193.130.sh \"$DT_BASEURL/api/v1/deployment/installer/gateway/unix/latest?arch=x86&flavor=default\" --header=\"Authorization:Api-Token $DT_PAAS_TOKEN\"" >> $USERDATA_FILE
    echo "  - sudo /bin/sh /tmp/Dynatrace-ActiveGate-Linux-x86-1.193.130.sh" >> $USERDATA_FILE
    echo "" >> $USERDATA_FILE

    # us-east-1 ... Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-085925f297f89fce1 (64-bit x86) / ami-05d7ab19b28efa213 (64-bit Arm)
    IMAGE_AMI=ami-085925f297f89fce1
    
    aws ec2 run-instances --image-id $IMAGE_AMI --count 1 --instance-type t2.small \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Owner,Value=dynatrace-modernize-workshop},{Key=Name,Value='$HOSTNAME'}]' 'ResourceType=volume,Tags=[{Key=Owner,Value=dynatrace-modernize-workshop},{Key=Name,Value='$HOSTNAME'}]' \
    --instance-initiated-shutdown-behavior terminate \
    --key-name $AWS_KEYPAIR_NAME \
    --profile $AWS_PROFILE \
    --region $AWS_REGION \
    --user-data file://$USERDATA_FILE | jq -r '.Instances | .[].InstanceId'

    if [ $? != 0 ]; then
        echo "Aborting due to VM creation error."
        break
    fi
  fi
}

#*********************************
provision_eztravel_vm()
{
  HOSTGROUP=$1
  HOSTNAME="workshop-ez-$HOSTGROUP"
  SECURITY_GROUP="security_group_workshop-ez"

  echo "Checking if $SECURITY_GROUP already exists"
  CHECK="$(does_security_group_exist)"
  if [ "$CHECK" == "true" ]; then
    echo "Skipping, security group $SECURITY_GROUP exists"
    echo ""
  else
    echo ""
    echo "Adding $SECURITY_GROUP"
    aws ec2 create-security-group --group-name $SECURITY_GROUP --description $SECURITY_GROUP 
    aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 80 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 8094 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 8091 --cidr 0.0.0.0/0
  fi

  echo "Checking if VM $HOSTNAME already exists"
  CHECK="$(does_vm_exist)"
  echo "CHECK = $CHECK for $HOSTNAME"
  if [ "$CHECK" == "true" ]; then
    echo "Skipping, host $HOSTNAME exists"
    echo ""
  else
    echo ""
    echo "Adding $HOSTNAME"
    
    USERDATA_TEMPLATE_FILE=user_data_ez.template
    USERDATA_FILE=user_data_ez.gen
    # us-east-1 ... Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-085925f297f89fce1 (64-bit x86) / ami-05d7ab19b28efa213 (64-bit Arm)
    IMAGE_AMI=ami-085925f297f89fce1

    #set Dynatrace secrets userdata in file
    cat $USERDATA_TEMPLATE_FILE | \
      sed 's~REPLACE_HOST_GROUP~'"$HOST_CTR"'~' | \
      sed 's~REPLACE_URL~'"$DT_BASEURL"'~' | \
      sed 's~REPLACE_TOKEN~'"$DT_PAAS_TOKEN"'~' > $USERDATA_FILE
    
    aws ec2 run-instances --image-id $IMAGE_AMI --count 1 --instance-type t2.medium \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Owner,Value=dynatrace-modernize-workshop},{Key=Name,Value='$HOSTNAME'}]' 'ResourceType=volume,Tags=[{Key=Owner,Value=dynatrace-modernize-workshop},{Key=Name,Value='$HOSTNAME'}]' \
    --instance-initiated-shutdown-behavior terminate \
    --key-name $AWS_KEYPAIR_NAME \
    --profile $AWS_PROFILE \
    --security-groups $SECURITY_GROUP \
    --region $AWS_REGION \
    --user-data file://$USERDATA_FILE | jq -r '.Instances | .[].InstanceId'

    if [ $? != 0 ]; then
        echo "Aborting due to VM creation error."
        break
    fi
  fi
}

#*********************************
# cloud-init logs: /var/log/cloud-init.log
provision_eztravel_docker_vm()
{
  HOSTGROUP=$1
  HOSTNAME="workshop-ez-docker-$HOSTGROUP"
  SECURITY_GROUP="security_group_workshop-ez-docker"

  echo "Checking if $SECURITY_GROUP already exists"
  CHECK="$(does_security_group_exist)"
  if [ "$CHECK" == "true" ]; then
    echo "Skipping, security group $SECURITY_GROUP exists"
    echo ""
  else
    echo ""
    echo "Adding $SECURITY_GROUP"
    aws ec2 create-security-group --group-name $SECURITY_GROUP --description $SECURITY_GROUP 
    aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 80 --cidr 0.0.0.0/0
  fi

  echo "Checking if VM $HOSTNAME already exists"
  CHECK="$(does_vm_exist)"
  if [ "$CHECK" == "true" ]; then
    echo "Skipping, host $HOSTNAME exists"
    echo ""
  else
    echo ""
    echo "Adding $HOSTNAME"
    
    USERDATA_TEMPLATE_FILE=user_data_ez_docker.template
    USERDATA_FILE=user_data_ez_docker.gen
    # us-east-1 ... Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-085925f297f89fce1 (64-bit x86) / ami-05d7ab19b28efa213 (64-bit Arm)
    IMAGE_AMI=ami-085925f297f89fce1

    #set Dynatrace secrets userdata in file
    cat $USERDATA_TEMPLATE_FILE | \
      sed 's~REPLACE_HOST_GROUP~'"$HOST_CTR"'~' | \
      sed 's~REPLACE_URL~'"$DT_BASEURL"'~' | \
      sed 's~REPLACE_TOKEN~'"$DT_PAAS_TOKEN"'~' > $USERDATA_FILE
    
    aws ec2 run-instances --image-id $IMAGE_AMI --count 1 --instance-type t2.medium \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Owner,Value=dynatrace-modernize-workshop},{Key=Name,Value='$HOSTNAME'}]' 'ResourceType=volume,Tags=[{Key=Owner,Value=dynatrace-modernize-workshop},{Key=Name,Value='$HOSTNAME'}]' \
    --instance-initiated-shutdown-behavior terminate \
    --key-name $AWS_KEYPAIR_NAME \
    --profile $AWS_PROFILE \
    --security-groups $SECURITY_GROUP \
    --region $AWS_REGION \
    --user-data file://$USERDATA_FILE | jq -r '.Instances | .[].InstanceId'

    if [ $? != 0 ]; then
        echo "Aborting due to VM creation error."
        break
    fi
  fi
}

#*********************************
echo "==================================================================================="
echo "*** Adding $NUM_HOSTS hosts of type $HOST_TYPE ***"
HOST_CTR=1
while [ $HOST_CTR -le $NUM_HOSTS ]
do

  case $HOST_TYPE in
  ez)
    echo "Adding $HOST_TYPE ($HOST_CTR of $NUM_HOSTS): Starting: $(date)"
    provision_eztravel_vm $HOST_CTR
    ;;
  ez-docker)
    echo "Adding $HOST_TYPE ($HOST_CTR of $NUM_HOSTS): Starting: $(date)"
    provision_eztravel_docker_vm $HOST_CTR
    ;;
  active-gate)
    echo "Adding $HOST_TYPE ($HOST_CTR of $NUM_HOSTS): Starting: $(date)"
    provision_linux_active_gate $HOST_CTR
    ;;
  *) 
    echo "Invalid HOST_TYPE option. Valid values are 'ez','ez-backend','active-gate'"
    break
    ;;
  esac
  echo "Complete: $(date)"
  HOST_CTR=$(( $HOST_CTR + 1 ))

done

echo "*** Done Provision Host of type $HOST_TYPE ***"
echo "==================================================================================="
