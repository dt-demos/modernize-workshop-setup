#!/bin/bash

PROBLEM_PATTERN=CPULoadJourneyService
ENABLED=$1

if [ $? -eq 0 ]; then
    echo ""
    echo "--------------------------------------------------------------------------------------"
    echo "$PROBLEM_PATTERN"
    echo "--------------------------------------------------------------------------------------"
    echo "This plugin causes additional high CPU usage when searching for a journey.  "
    echo "It is executed a number of times, regardless whether the requested journey is found or not"
fi

./_setProblemPattern.sh $PROBLEM_PATTERN $ENABLED
