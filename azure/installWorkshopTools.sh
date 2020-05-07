#!/bin/bash

# jq - https://stedolan.github.io/jq

if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing 'jq' utility ..."
  sudo apt-get install -y jq
fi

# Install Docker - https://docs.docker.com/engine/install/ubuntu/
if ! [ -x "$(command -v docker)" ]; then

  sudo apt-get update
  sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  
  sudo docker run hello-world
fi