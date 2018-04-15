#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0)

# Add defaults to variables controlling the setup system
VAGRANT=${VAGRANT:-0}
DOCKER=${DOCKER:-0}
export DOCKER

if [[ $VAGRANT -eq 1 ]]; then
    USAGE="Usage: $(basename $0)  domain  server-ip  server-name"
    export DOMAIN=${1:?$USAGE}
    export SERVER_IP=${2:?$USAGE}
    export SERVER_NAME=${3:?$USAGE}
    echo "Using vagrant config"
else

    source "${DIR}/config-standalone.sh"
    echo "Using standalone config"
fi

source "${DIR}/config.sh"

# Main

export DEBIAN_FRONTEND=noninteractive

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
