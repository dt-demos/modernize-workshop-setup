#!/bin/bash

echo ""
echo "=========================================="
echo "Provisioning Azure workshop resources"
echo "Starting: $(date)"
echo "=========================================="
./loadDynatraceConfig.sh
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