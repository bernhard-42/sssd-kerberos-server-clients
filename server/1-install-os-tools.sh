#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

export DEBIAN_FRONTEND=noninteractive

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.1 Updating apt"
apt-get update
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.2 Installing OS tools"

apt-get install -y ntp ntpdate rng-tools gnutls-bin ssl-cert
loginfo "... done\n"
