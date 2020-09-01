#!/bin/bash

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

    deleteConfig dashboards modernize-workshop

    setFrequentIssueDetectionOn

    setServiceAnomalyDetection ./dynatrace/service-anomalydetectionDefault.json

    deleteConfig "service/customServices/java" CheckDestination

    deleteConfig managementZones ez-travel-docker
    deleteConfig managementZones ez-travel-monolith

    deleteConfig autoTags workshop-group

    # the delete is for the application name so need to do make call for each rule for each app
    deleteConfig "applicationDetectionRules" EasyTravelOrange
    deleteConfig "applicationDetectionRules" EasyTravelOrange
    deleteConfig "applicationDetectionRules" EasyTravelOrangeDocker

    deleteConfig "applications/web" EasyTravelOrange
    deleteConfig "applications/web" EasyTravelOrangeDocker

    echo ""
    echo "*** Done Removing Dynatrace config ***"
    echo ""
fi