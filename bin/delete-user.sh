#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

if [ "x$1" == "x" ]; then
    echo "Usage: $(basename $0)" '<uid>'
    exit 1
fi

U_ID=$1
GROUP_NAME=$U_ID

if [ ${USE_KRB5} -eq 1 ]; then
    loginfo "Deleting user in KDC"

    kadmin.local -q "delprinc -force ${U_ID}"

    loginfo "done"
fi

loginfo "Deleting users group in LDAP"

$DIR/delete-group.sh "${GROUP_NAME}"

loginfo "done"


loginfo "Deleting user in LDAP (uid=${U_ID} gid=${GROUP_ID})":

cat << EOF > ./user.ldif
dn: uid=${U_ID},ou=People,${LDAP_BASE}
changetype: delete
EOF
    cat ./user.ldif

ldapmodify -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./user.ldif

rm -f ./user.ldif

loginfo "done"


loginfo "Deleting group memberships"

ldapsearch -LLL -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -b ${LDAP_BASE} "(memberUid=${U_ID})" dn | grep -Ev "^\s*$" \
| while read DN; do
    loginfo "Deleting from ${DN}:"
    cat << EOF > ./user.ldif
$DN
changetype: modify
delete: memberUid
memberUid: ${U_ID}
EOF
    ldapmodify -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./user.ldif
done
loginfo "done"


