#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "4.1 Populating LDAP database"

cat > /root/config.ldif << EOF
dn: ou=People,${LDAP_BASE}
objectClass: organizationalUnit
ou: People

dn: ou=Groups,${LDAP_BASE}
objectClass: organizationalUnit
ou: Groups

EOF

ldapadd -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f /root/config.ldif

rm /root/config.ldif

loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "4.2 Configuring PHP LDAP"

if [[ ${USE_PHPLDAPADMIN} -eq 1 ]]; then

    sed -i "s|^\$servers->setValue('server','base',.*|\$servers->setValue('server','base',array('${LDAP_BASE}'));|" /etc/phpldapadmin/config.php
    sed -i "s|^\$servers->setValue('login','bind_id',.*|\$servers->setValue('login','bind_id','${LDAP_ADMIN}');|" /etc/phpldapadmin/config.php
    sed -i "s|^\$config->custom->appearance['hide_template_warning'] = .*|\$config->custom->appearance['hide_template_warning'] = true;|" /etc/phpldapadmin/config.php

    restart_service apache2

    loginfo "LDP Admin Tool: http://$(hostname -i):${PHPLDAPADMIN_PORT}/phpldapadmin/"
else
    loginfo "Skipped"
fi
loginfo "... done\n"
