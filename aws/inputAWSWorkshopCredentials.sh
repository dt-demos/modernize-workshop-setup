#!/bin/bash

YLW='\033[1;33m'
NC='\033[0m'

CREDS_FILE=./creds.json
CREDS_TEMPLATE_FILE=./creds.template

if [ -f "$CREDS_FILE" ]
then
    DT_BASEURL=$(cat creds.json | jq -r '.DT_BASEURL')
    DT_API_TOKEN=$(cat creds.json | jq -r '.DT_API_TOKEN')
    DT_PAAS_TOKEN=$(cat creds.json | jq -r '.DT_PAAS_TOKEN')
    DT_ENVIRONMENT_ID=$(cat creds.json | jq -r '.DT_ENVIRONMENT_ID')
    AWS_PROFILE=$(cat creds.json | jq -r '.AWS_PROFILE')
    AWS_REGION=$(cat creds.json | jq -r '.AWS_REGION')
    AWS_KEYPAIR_NAME=$(cat creds.json | jq -r '.AWS_KEYPAIR_NAME')
    RESOURCE_PREFIX=$(cat creds.json | jq -r '.RESOURCE_PREFIX')
fi

clear
echo "==================================================================="
echo -e "${YLW}Please enter your Dynatrace credentials as requested below: ${NC}"
echo "Press <enter> to keep the current value"
echo "==================================================================="
read -p "Your Last Name           (current: $RESOURCE_PREFIX) : " RESOURCE_PREFIX_NEW
echo    "Dynatrace Base URL       (ex. https://ABC.live.dynatrace.com) "
read -p "                         (current: $DT_BASEURL) : " DT_BASEURL_NEW
read -p "Dynatrace Environment ID (current: $DT_ENVIRONMENT_ID) : " DT_ENVIRONMENT_ID_NEW
read -p "Dynatrace PaaS Token     (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "Dynatrace API Token      (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
#read -p "AWS CLI Profile          (current: $AWS_PROFILE) : " AWS_PROFILE_NEW
#read -p "AWS Region               (current: $AWS_REGION) : " AWS_REGION_NEW
#read -p "AWS Keypair Name         (current: $AWS_KEYPAIR_NAME) : " AWS_KEYPAIR_NAME_NEW
echo "==================================================================="
echo ""

# set value to new input or default to current value
RESOURCE_PREFIX=${RESOURCE_PREFIX_NEW:-$RESOURCE_PREFIX}
DT_BASEURL=${DT_BASEURL_NEW:-$DT_BASEURL}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
DT_ENVIRONMENT_ID=${DT_ENVIRONMENT_ID_NEW:-$DT_ENVIRONMENT_ID}
AWS_PROFILE=${AWS_PROFILE_NEW:-$AWS_PROFILE}
AWS_REGION=${AWS_REGION_NEW:-$AWS_REGION}
#AWS_KEYPAIR_NAME=${AWS_KEYPAIR_NAME_NEW:-$AWS_KEYPAIR_NAME}
AWS_KEYPAIR_NAME="$RESOURCE_PREFIX-dynatrace-modernize-workshop"

#remove trailing / if the have it
if [ "${DT_BASEURL: -1}" == "/" ]; then
  echo "removing / from DT_BASEURL"
  DT_BASEURL="$(echo ${DT_BASEURL%?})"
fi

echo -e "Please confirm all are correct:"
echo ""
echo "Your Last Name           : $RESOURCE_PREFIX"
echo "Dynatrace Base URL       : $DT_BASEURL"
echo "Dynatrace Environment ID : $DT_ENVIRONMENT_ID"
echo "Dynatrace PaaS Token     : $DT_PAAS_TOKEN"
echo "Dynatrace API Token      : $DT_API_TOKEN"
#echo "AWS CLI Profile          : $AWS_PROFILE"
#echo "AWS Region               : $AWS_REGION"
#echo "AWS Keypair Name         : $AWS_KEYPAIR_NAME"
echo "==================================================================="
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    cp $CREDS_FILE $CREDS_FILE.bak 2> /dev/null
    rm $CREDS_FILE 2> /dev/null

    cat $CREDS_TEMPLATE_FILE | \
      sed 's~RESOURCE_PREFIX_PLACEHOLDER~'"$RESOURCE_PREFIX"'~' | \
      sed 's~AWS_PROFILE_PLACEHOLDER~'"$AWS_PROFILE"'~' | \
      sed 's~AWS_REGION_PLACEHOLDER~'"$AWS_REGION"'~' | \
      sed 's~AWS_KEYPAIR_NAME_PLACEHOLDER~'"$AWS_KEYPAIR_NAME"'~' | \
      sed 's~DT_ENVIRONMENT_ID_PLACEHOLDER~'"$DT_ENVIRONMENT_ID"'~' | \
      sed 's~DT_BASEURL_PLACEHOLDER~'"$DT_BASEURL"'~' | \
      sed 's~DT_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' | \
      sed 's~DT_PAAS_TOKEN_PLACEHOLDER~'"$DT_PAAS_TOKEN"'~' > $CREDS_FILE

    echo ""
    echo "Saved credential values to: $CREDS_FILE"
    echo ""
    echo "==================================================================="
    cat $CREDS_FILE
fi
