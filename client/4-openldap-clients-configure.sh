#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "4 Install CA certificate"
cp ${REPO_PATH}/cacert.pem /etc/ssl/certs/
echo -e "\nTLS_CACERT /etc/ssl/certs/cacert.pem" >> /etc/openldap/ldap.conf
loginfo "... done\n"
