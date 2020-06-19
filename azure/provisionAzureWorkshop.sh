#!/bin/bash

load_dynatrace_config()
{
    # workshop config like tags, dashboard, MZ
    # doing this change directory business, so that can share script across AWS and Azure
    cp creds.json ../dynatrace/creds.json
    cd ../dynatrace
    ./setupDynatraceConfig.sh
    cd ../azure
}

echo ""
echo "=========================================="
echo "Provisioning Azure workshop resources"
echo "Starting: $(date)"
echo "=========================================="

load_dynatrace_config

# setup active gate
./createHosts.sh active-gate

# workshop VMs with easyTravel
./createHosts.sh ez 1 yes
./createHosts.sh ez-docker 1 yes

#./createHosts.sh win 3 yes
#./createHosts.sh linux 6 yes
echo ""
echo "============================================="
echo "Provision Azure workshop resources COMPLETE"
echo "End: $(date)"
echo "============================================="
echo ""