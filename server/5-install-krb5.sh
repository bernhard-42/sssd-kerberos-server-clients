#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"


export DEBIAN_FRONTEND=noninteractive

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5 Installing Kerberos modules"

cat > /root/debconf-krb5.conf << EOF
krb5-config krb5-config/default_realm string ${REALM}
EOF

cat /root/debconf-krb5.conf | debconf-set-selections
apt-get install -y krb5-kdc krb5-admin-server krb5-kdc-ldap
rm /root/debconf-krb5.conf

loginfo "done\n"
