#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "6 Creating krb5.conf"

cat > /etc/krb5.conf << EOF
[libdefaults]
    default_realm = ${REALM}
    kdc_timesync = 1
    ccache_type = 4
    forwardable = true
    proxiable = true

[logging]
        kdc = FILE:/var/log/krb5/krb5kdc.log
        admin_server = FILE:/var/log/krb5/kadmind.log
        default = SYSLOG:NOTICE:DAEMON
        
[realms]
    ${REALM} = {
        kdc = ${KDC_IP}
        admin_server = ${KDC_IP}
    }

[domain_realm]
    ${DOMAIN} = ${REALM}
    .${DOMAIN} = ${REALM}

EOF

loginfo "done\n"
