#!/bin/bash

echo ""
echo "=========================================="
echo "Provisioning Azure workshop resources"
echo "Starting: $(date)"
echo "=========================================="
./createHosts.sh ez
./createHosts.sh ez-backend yes
./createHosts.sh win 3 yes
./createHosts.sh linux 3 yes
echo ""
echo "============================================="
echo "Provision Azure workshop resources COMPLETE"
echo "End: $(date)"
echo "============================================="
echo ""