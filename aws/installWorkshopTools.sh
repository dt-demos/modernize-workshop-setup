#!/bin/bash

# jq
# https://stedolan.github.io/jq
if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing 'jq' utility ..."
  sudo yum install jq -y
fi

# Upgrade AWS cli
if [ `aws --version | grep "aws-cli/2" | wc -l` == "0" ]; then
  echo "Updating 'AWS cli' to version 2 ..."
  sudo rm /usr/bin/aws
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

# update path
#echo 'export PATH="$HOME/bin:/usr/local/bin:$PATH"' >> ~/.bashrc
#export PATH="$HOME/bin:/usr/local/bin:$PATH"

