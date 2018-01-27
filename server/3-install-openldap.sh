#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

export DEBIAN_FRONTEND=noninteractive


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "3 Installing packages"

cat > /root/debconf-slapd.conf << EOF
slapd shared/organization string ACME AG
slapd slapd/backend select MDB
slapd slapd/domain string ${DOMAIN}
slapd slapd/dump_database select when needed
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/internal/adminpw password ${LDAP_PASSWORD}
slapd slapd/internal/generated_adminpw password ${LDAP_PASSWORD}
slapd slapd/invalid_config boolean true
slapd slapd/move_old_database boolean false
slapd slapd/no_configuration boolean false
slapd slapd/password1 password ${LDAP_PASSWORD}
slapd slapd/password2 password ${LDAP_PASSWORD}
slapd slapd/password_mismatch note
slapd slapd/ppolicy_schema_needs_update select abort installation
slapd slapd/purge_database boolean false
slapd slapd/unsafe_selfwrite_acl note
EOF

cat /root/debconf-slapd.conf | debconf-set-selections
apt-get install -y ldap-utils slapd phpldapadmin
rm /root/debconf-slapd.conf

loginfo "Validation"
loginfo "LDAP admin in $(ldapsearch -x -LLL -H ldap:/// -b dc=${ORG},dc=${TLD} dn)"
loginfo "... done\n"
