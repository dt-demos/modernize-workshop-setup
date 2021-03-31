#!/bin/bash

LAB_NAME=$1

if [ -z "$LAB_NAME" ]
then
    echo "Missing LAB_NAME environment variable"
    exit 1
fi

setup_monolith() {

    echo "----------------------------------------------------"
    echo "Setup Tools"
    echo "----------------------------------------------------"
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    apt-get install -y jq
    curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  
    echo "----------------------------------------------------"
    echo "Start copy_docker"
    echo "----------------------------------------------------"
    rm -rf scripts/
    mkdir -p scripts

    echo "copy docker compose files"
    git clone https://github.com/dt-orders/overview.git
    cp overview/docker-compose/docker-compose-monolith.yaml scripts/docker-compose.yaml
    rm -rf overview/

    echo "copy browser files"
    git clone https://github.com/dt-orders/browser-traffic.git
    cp browser-traffic/start-browser.sh scripts/start-browser.sh
    cp browser-traffic/stop-browser.sh scripts/stop-browser.sh
    rm -rf browser-traffic/

    echo "copy load files"
    git clone https://github.com/dt-orders/load-traffic.git
    cp load-traffic/start-load.sh scripts/start-load.sh
    cp load-traffic/stop-load.sh scripts/stop-load.sh
    rm -rf load-traffic/

    echo "----------------------------------------------------"
    echo "Start start_docker()"
    echo "----------------------------------------------------"
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)
    
    echo "Starting docker-compose"
    docker-compose -f scripts/docker-compose.yaml up -d

    echo "Waiting 30 seconds for app to come up"
    sleep 30

    echo "Starting browser traffic on: $PUBLIC_IP"
    cd scripts
    ./stop-browser.sh
    ./start-browser.sh "http://$PUBLIC_IP" 1000000

    echo "Starting load traffic"
    ./stop-load.sh
    ./start-load.sh 172.17.0.1 80 10000000
    cd ..

    echo "Waiting 10 seconds"
    sleep 10
    
    echo "docker ps"
    docker ps

    echo "----------------------------------------------------"
    echo "End start_docker()"
    echo "----------------------------------------------------"
}

case "$LAB_NAME" in
    "monolith") 
        clear
        echo "===================================================="
        echo "Setting up: monolith" 
        echo "===================================================="
        setup_monolith
        ;;
    *) 
        echo "Invalid LAB_NAME environment variable"
        echo "Must be 'monolith' or 'bastion'" 
        exit 1
        ;;
esac

echo "===================================================="
echo "Setup Complete" 
echo "===================================================="
echo ""