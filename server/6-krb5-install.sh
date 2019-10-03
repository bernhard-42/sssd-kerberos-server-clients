#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

export DEBIAN_FRONTEND=noninteractive

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "6 Installing Kerberos modules"

cat > /root/debconf-krb5.conf << EOF
krb5-config krb5-config/default_realm string ${REALM}
EOF

cat /root/debconf-krb5.conf | debconf-set-selections
apt-get install -y krb5-kdc krb5-admin-server 
# force docs to be installed
sed -i 's:^path-exclude=/usr/share/doc/\*:# &:' -i  /etc/dpkg/dpkg.cfg.d/excludes
apt-get install -y krb5-kdc-ldap
# restore default
sed -i 's:^# \(path-exclude=/usr/share/doc/\*\):\1:'  /etc/dpkg/dpkg.cfg.d/excludes
rm /root/debconf-krb5.conf

loginfo "done\n"
