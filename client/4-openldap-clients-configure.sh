#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "4 Install CA certificate"

if is_centos7; then
    LDAP_CONF=/etc/openldap/ldap.conf
else
    LDAP_CONF=/etc/ldap/ldap.conf
fi

cp ${REPO_PATH}/cacert.pem /etc/ssl/certs/
echo -e "\nTLS_CACERT /etc/ssl/certs/cacert.pem" >> $LDAP_CONF
loginfo "... done\n"
