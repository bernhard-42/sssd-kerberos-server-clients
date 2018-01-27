#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

if [ "x$2" == "x" ]; then
    echo "Usage: $(basename $0)" '<group-id> <group-name>'
    exit 1
fi

loginfo "Creating group (gid=${GROUP_ID} name='${GROUP_NAME/\%20/ }'):"

GROUP_ID=$1
GROUP_NAME=$2

cat > /root/group.ldif << EOF
dn: cn=${GROUP_NAME/\%20/ },ou=Groups,${BASE}
objectClass: posixGroup
cn: ${GROUP_NAME/\%20/ }
gidNumber: ${GROUP_ID}
EOF

ldapadd -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f /root/group.ldif

rm -f /root/group.ldif

loginfo "done\n"
