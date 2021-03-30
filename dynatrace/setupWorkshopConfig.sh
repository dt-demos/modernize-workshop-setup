#!/bin/bash

# this will read in creds.json and export URL and TOKEN as environment variables
source ./dynatraceConfig.lib

echo ""
echo "-----------------------------------------------------------------------------------"
echo "Setting up Dynatrace config for $DT_BASEURL"
echo "-----------------------------------------------------------------------------------"
echo ""

# copy monaco binary
rm -f monaco-binary
wget -O monaco-binary https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/download/v1.5.0/monaco-linux-amd64
chmod +x monaco-binary

# run monaco configuration
# add the -dry-run argument to test
#monaco -dry-run --environments ./monaco/environments.yaml --project eztravel ./monaco/projects
monaco --environments ./monaco/environments.yaml --project eztravel ./monaco/projects

# custom API calls
setFrequentIssueDetectionOff
setServiceAnomalyDetection ./custom/service-anomalydetection.json

echo ""
echo "-----------------------------------------------------------------------------------"
echo "Done Setting up Dynatrace config"
echo "-----------------------------------------------------------------------------------"
