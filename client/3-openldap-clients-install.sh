#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "3 Installing OpenLDAP cliewnt module"

if is_centos7; then
    yum install -y openldap-clients
else
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y openldap-utils
fi

loginfo "done\n"
