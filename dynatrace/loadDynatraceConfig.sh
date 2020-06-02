#!/bin/bash

source ./dynatraceConfig.lib

echo ""
echo "*** Setting up Dynatrace config for $DT_BASEURL ***"
echo

addConfig dashboards modernize-workshop ./dynatrace/dashboard-workshop.json

setFrequentIssueDetectionOff

setServiceAnomalyDetection ./dynatrace/service-anomalydetection.json

addConfig "service/customServices/java" CheckDestination ./dynatrace/customService-CheckDestination.json

addConfig managementZones ez-travel ./dynatrace/mz-eztravel.json
addConfig managementZones ez-travel-docker ./dynatrace/mz-eztravel-docker.json

addConfig autoTags workshop-group ./dynatrace/autoTags-workshop-group.json

addConfig "applications/web" EasyTravelOrange ./dynatrace/app-EasyTravelOrange.json
addConfig "applications/web" EasyTravelOrangeDocker ./dynatrace/app-EasyTravelOrangeDocker.json

echo ""
echo "*** Done Setting up Dynatrace config ***"
echo ""