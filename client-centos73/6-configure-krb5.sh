#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "6 Creating krb5.conf"

cat > /etc/krb5.conf << EOF
[libdefaults]
    default_realm = ${REALM}
    kdc_timesync = 1
    ccache_type = 4
    forwardable = true
    proxiable = true


[realms]
    ${REALM} = {
        kdc = ${KDC_NAME}
        admin_server = ${KDC_NAME}
    }

[domain_realm]
    ${DOMAIN} = ${REALM}
    .${DOMAIN} = ${REALM}

EOF

loginfo "done\n"
