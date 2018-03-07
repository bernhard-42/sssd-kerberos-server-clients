#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5 Installing Kerberos modules"

if is_centos7; then
    yum install -y krb5-workstation pam_krb5
else
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y krb5-user
fi

loginfo "done\n"
