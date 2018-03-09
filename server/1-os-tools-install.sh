#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

export DEBIAN_FRONTEND=noninteractive

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.1 Updating apt"
apt-get update
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.2 Installing OS tools"

if [[ $DOCKER -eq 1 ]]; then
    apt-get install -y net-tools gnutls-bin ssl-cert
else
    apt-get install -y ntp rng-tools gnutls-bin ssl-cert
fi
loginfo "... done\n"
