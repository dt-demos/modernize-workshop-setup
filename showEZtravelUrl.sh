#!/bin/bash

echo ""
echo "My hostname    : $(hostname)"
echo "My public  IP  : $(curl -s http://checkip.amazonaws.com/)"
echo "My private IP  : $(hostname -i | awk '{ print $1'})"
echo ""
echo "easyTravel URL : http://$(curl -s http://checkip.amazonaws.com/)"
