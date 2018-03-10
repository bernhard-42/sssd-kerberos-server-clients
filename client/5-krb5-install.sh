#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5 Installing Kerberos modules"

if is_centos7; then
    yum install -y krb5-workstation pam_krb5
elif is_ubuntu16; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y krb5-user
elif is_sles12; then
    zypper install -y krb5-client
else
    logerr "OS not supprted"
fi
mkdir -p /var/log/krb5/
chmod 700 /var/log/krb5/

loginfo "done\n"
