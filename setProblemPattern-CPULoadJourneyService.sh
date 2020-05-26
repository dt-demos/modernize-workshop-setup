#!/bin/bash

PROBLEM_PATTERN=SlowApacheWebserver
ENABLED=$1

./_setProblemPattern.sh $PROBLEM_PATTERN $ENABLED

echo ""
echo "--------------------------------------------------------------------------------------"
echo "$PROBLEM_PATTERN"
echo "--------------------------------------------------------------------------------------"
echo "Causes a response time issue impacting multiple services. " 
echo "Root cause is checkDesination Service in Journey Service from a high CPU function call"
