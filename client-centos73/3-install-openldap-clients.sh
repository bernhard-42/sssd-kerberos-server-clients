#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "3 Installing OpenLDAP cliewnt module"

yum install -y openldap-clients

loginfo "done\n"
