#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "3 Installing OpenLDAP client module"

if is_centos7; then
    yum install -y openldap-clients
elif is_ubuntu16; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y ldap-utils
elif is_sles12; then
    zypper install -y openldap2-client
else
    logerr "OS not supprted"
fi

loginfo "done\n"
