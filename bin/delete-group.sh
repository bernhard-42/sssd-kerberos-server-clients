#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

if [ "x$1" == "x" ]; then
    echo "Usage: $(basename $0)" '<group-name>'
    exit 1
fi

GROUP_NAME=${1/\%20/ }

loginfo "Deleting group (name='${GROUP_NAME}'):"

cat > ./group.ldif << EOF
dn: cn=${GROUP_NAME},ou=Groups,${BASE}
changetype: delete
EOF

ldapmodify -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./group.ldif

rm -f ./group.ldif

loginfo "done\n"
