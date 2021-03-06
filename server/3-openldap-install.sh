#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

export DEBIAN_FRONTEND=noninteractive

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "3.1 Installing LDAP utilities"

cat > /root/debconf-slapd.conf << EOF
slapd shared/organization string ${LDAP_ORG}
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
apt-get install -y ldap-utils slapd
rm /root/debconf-slapd.conf
start_service slapd

loginfo "3.2 Validation"
loginfo "LDAP admin in $(ldapsearch -x -LLL -H ldap:/// -b ${LDAP_BASE} dn)"
loginfo "... done\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "3.3 Installing PHPLdapAdmin"

if [[ ${USE_PHPLDAPADMIN} -eq 1 ]]; then
    apt-get install -y phpldapadmin
    sed -i "s/:80/:${PHPLDAPADMIN_PORT}/" /etc/apache2/sites-enabled/000-default.conf
    sed -i "s/ 80/ ${PHPLDAPADMIN_PORT}/" /etc/apache2/ports.conf
    start_service apache2
fi
loginfo "... done\n"
