#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7 Installing SSSD"

if is_centos7; then
    yum install -y sssd sssd-tools
else
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y sssd sssd-tools
fi

loginfo "done\n"
