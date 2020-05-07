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
    DT_CONFIG_TOKEN=$(cat creds.json | jq -r '.DT_CONFIG_TOKEN')
fi

#clear
echo "==================================================================="
echo -e "${YLW}Please enter your Dynatrace credentials as requested below: ${NC}"
echo "Press <enter> to keep the current value"
echo "==================================================================="
echo    "Dynatrace Base URL     (ex. https://ABC.live.dynatrace.com) "
read -p "                       (current: $DT_BASEURL) : " DT_BASEURL_NEW
read -p "Dynatrace API Token    (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token   (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "Dynatrace Config Token (current: $DT_CONFIG_TOKEN) : " DT_CONFIG_TOKEN_NEW
echo "==================================================================="
echo ""

# set value to new input or default to current value
DT_BASEURL=${DT_BASEURL_NEW:-$DT_BASEURL}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
DT_CONFIG_TOKEN=${DT_CONFIG_TOKEN_NEW:-$DT_CONFIG_TOKEN}

echo -e "Please confirm all are correct:"
echo ""
echo "Dynatrace Environmen         : $DT_BASEURL"
echo "Dynatrace API Token          : $DT_API_TOKEN"
echo "Dynatrace PaaS Token         : $DT_PAAS_TOKEN"
echo "Dynatrace Config Token       : $DT_CONFIG_TOKEN"

echo "==================================================================="
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    cp $CREDS_FILE $CREDS_FILE.bak 2> /dev/null
    rm $CREDS_FILE 2> /dev/null

    cat $CREDS_TEMPLATE_FILE | \
      sed 's~DYNATRACE_BASEURL_PLACEHOLDER~'"$DT_BASEURL"'~' | \
      sed 's~DYNATRACE_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN_PLACEHOLDER~'"$DT_PAAS_TOKEN"'~' | \
      sed 's~DYNATRACE_CONFIG_TOKEN_PLACEHOLDER~'"$DT_CONFIG_TOKEN"'~' > $CREDS_FILE

    echo ""
    echo "Saves credential values to: $CREDS_FILE"
    echo ""
    cat $CREDS_FILE
fi
