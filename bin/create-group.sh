#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

if [ "x$2" == "x" ]; then
    echo "Usage: $(basename $0)" '<group-id> <group-name>'
    exit 1
fi

GROUP_ID=$1
GROUP_NAME=${2/\%20/ }

loginfo "Creating group (gid=${GROUP_ID} name='${GROUP_NAME}'):"

cat  << EOF > ./group.ldif
dn: cn=${GROUP_NAME},ou=Groups,${LDAP_BASE}
objectClass: posixGroup
cn: ${GROUP_NAME}
gidNumber: ${GROUP_ID}
EOF

ldapadd -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./group.ldif

rm -f ./group.ldif

loginfo "done\n"
