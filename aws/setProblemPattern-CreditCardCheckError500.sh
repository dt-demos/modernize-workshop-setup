#!/bin/bash

PROBLEM_PATTERN=CreditCardCheckError500
ENABLED=$1

if [ $? -eq 0 ]; then
    echo ""
    echo "--------------------------------------------------------------------------------------"
    echo "$PROBLEM_PATTERN"
    echo "--------------------------------------------------------------------------------------"
    echo "Causes Error in the Booking Service"
    echo "Root cause is Communication plugin could not contact credit card verification application via named pipe"
    echo "in the Booking Service" 
fi

./_setProblemPattern.sh $PROBLEM_PATTERN $ENABLED
