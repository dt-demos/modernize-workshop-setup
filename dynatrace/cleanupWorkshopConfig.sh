#!/bin/bash

# this will read in creds.json and export URL and TOKEN as environment variables
source ./dynatraceConfig.lib

echo "==================================================================="
echo "About to Delete Dynatrace configuration on:"
echo "  $DT_BASEURL"
echo "==================================================================="
read -p "Proceed with cleanup? (y/n) : " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then

    echo ""
    echo "*** Removing Dynatrace config for $DT_BASEURL ***"
    echo

    # run monaco as code script
    PROJECT_BASE_PATH=./monaco/projects
    PROJECT=workshop
    ENVIONMENT_FILE=./monaco/environments.yaml

    cp $PROJECT_BASE_PATH/$PROJECT/delete.txt $PROJECT_BASE_PATH/$PROJECT/delete.yaml 
    monaco -v --environments $ENVIONMENT_FILE --project $PROJECT $PROJECT_BASE_PATH
    rm $PROJECT_BASE_PATH/$PROJECT/delete.yaml 

    # make custom API calls
    setFrequentIssueDetectionOn
    setServiceAnomalyDetection ./custom/service-anomalydetectionDefault.json

    echo ""
    echo "*** Done Removing Dynatrace config ***"
    echo ""
fi