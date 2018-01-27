#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5 Installing Kerberos modules"

yum install -y krb5-workstation pam_krb5

loginfo "done\n"
