#!/bin/bash

# contains functions called in this script
source ./azure.lib

load_dynatrace_config()
{
    # copy the service principal file previously geneated by create_service_principal()
    MONACO_BASE_FOLDER="../dynatrace/monaco/projects/eztravel"
    mkdir -p "$MONACO_BASE_FOLDER/azure-credentials"
    cp -f ./gen/azure-credentials.json "$MONACO_BASE_FOLDER/azure-credentials/azure-credentials.json"
    cp -f ./gen/config.yaml "$MONACO_BASE_FOLDER/azure-credentials/config.yaml"

    # this file is needed by the Dynatrace config scripts
    cp -f creds.json ../dynatrace/creds.json

    # this scripts will all monaco to add workshop config like tags, dashboard, MZ
    cd ../dynatrace
    ./setupWorkshopConfig.sh
    cd ../azure
}

create_hosts()
{
    # setup active gate
    createhost active-gate

    # workshop VMs with easyTravel
    createhost ez 1 yes
    createhost ez-docker 1 yes
}

echo ""
echo "=========================================="
echo "Provisioning Azure workshop resources"
echo "Starting: $(date)"
echo "=========================================="

createhost dt-orders-monolith 1 yes
#create_hosts
create_service_principal
load_dynatrace_config

echo ""
echo "============================================="
echo "Provision Azure workshop resources COMPLETE"
echo "End: $(date)"
echo "============================================="
echo ""