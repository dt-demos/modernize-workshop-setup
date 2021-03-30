# Welcome 

The folder contains the configuration files to support [Dynatrace Monitoring as Code](https://github.com/dynatrace-oss/dynatrace-monitoring-as-code) framework (a.k.a. monaco) and configuration using the [Dynatrace Configuration API](https://www.dynatrace.com/support/help/dynatrace-api/configuration-api/) for those few configurations not yet supported by monaco.  

# Usage

The `setupWorkshopConfig.sh` and `cleanupWorkshopConfig.sh` scripts will read `creds.json` file for Dynatrace URL and API token and set environment variables used by the scripts and expected by monaco.  This script calls monaco and the Dynatrace API to add or delete the configuration expected by the workshop.

The `dynatraceConfig.lib` is sourced by both scripts contains the logic to call the Dynatrace API.

# Prereqs

1. `creds.json` file that contains the these values.  
    * DT_BASEURL
    * DT_API_TOKEN

    NOTE: The `creds.json` file will be automatically copied by the `azure/provisionAzureWorkshop.sh` or `aws/provisionAWSWorkshop.sh` scripts.

2. Monaco Binary - Tested with [Dynatrace monoco binary 1.5.0](https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/tag/v1.5.0).