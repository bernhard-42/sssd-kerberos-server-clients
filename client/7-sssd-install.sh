#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7 Installing SSSD"

if is_centos7; then
    yum install -y sssd sssd-tools
elif is_ubuntu18; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y sssd sssd-tools
elif is_sles12; then
    systemctl stop nscd
    systemctl disable nscd
    zypper install -y sssd sssd-tools sssd-krb5 pam_krb5
else
    logerr "OS not supprted"
fi

loginfo "done\n"
