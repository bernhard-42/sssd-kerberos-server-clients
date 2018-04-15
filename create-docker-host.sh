#!/bin/bash

DIR=$(dirname $0)

if [[ $VAGRANT -eq 1 ]]; then
    USAGE="Usage: $(basename $0)  domain  server-ip  server-name"
    export DOMAIN=${1:?$USAGE}
    export SERVER_IP=${2:?$USAGE}
    export SERVER_NAME=${3:?$USAGE}
    echo "Using vagrant config"
else
    source "$DIR/config-standalone.sh"
    echo "Using standalone config"
fi

source "$DIR/config.sh"

apt-get update
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install -y docker-ce
