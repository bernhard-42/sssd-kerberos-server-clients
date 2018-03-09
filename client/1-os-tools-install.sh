#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.1 Initialising package manager"
if is_centos7; then
    yum makecache fast
else
    apt-get update
fi
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.2 Installing OS tools"
if is_centos7; then
    yum install -y ntp ntpdate rng-tools
else
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y ntp rng-tools
fi
loginfo "... done\n"
