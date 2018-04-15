#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

if [[ -z $6 ]]; then
    echo "Usage: $(basename $0)" '<uid-number> <uid> <first-name> <surname> <password> <group-name1,group-name2,...>'
    exit 1
fi

set -o errexit ; set -o nounset

UID_NUMBER=$1
U_ID=$2
FNAME=$3
SNAME=$4
PASSWORD=$5
GROUP_NAMES=$6

GROUP_ID=$UID_NUMBER
GROUP_NAME=$U_ID


$DIR/create-group.sh "${GROUP_ID}" "${GROUP_NAME}"


loginfo "Creating user in LDAP (id=${UID_NUMBER} uid=${U_ID} fname=${FNAME} sname=${SNAME} gid=${GROUP_ID} pw=${PASSWORD})":

SHA_PASSWORD=$(slappasswd -s ${PASSWORD})

cat << EOF > ./user.ldif
dn: uid=${U_ID},ou=People,${LDAP_BASE}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${U_ID}
sn: ${SNAME}
givenName: ${FNAME}
cn: ${FNAME} ${SNAME}
displayName: ${SNAME}, ${FNAME}
uidNumber: ${UID_NUMBER}
gidNumber: ${UID_NUMBER}
userPassword: ${SHA_PASSWORD}
gecos: ${FNAME} ${SNAME}
loginShell: /bin/bash
homeDirectory: /home/${U_ID}
EOF

ldapadd -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./user.ldif
rm -f ./user.ldif
loginfo "done"


loginfo "Adding group memberships"

IFS=',' read -r -a ALL_GROUP_NAMES <<< "$GROUP_NAMES"

for GROUP_NAME in "${ALL_GROUP_NAMES[@]}"; do
    cat << EOF > ./group.ldif 
dn: cn=${GROUP_NAME/\%20/ },ou=Groups,${LDAP_BASE}
changetype: modify
add: memberuid
memberuid: ${U_ID}
EOF
    cat ./group.ldif
    ldapmodify -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./group.ldif
    rm -f ./group.ldif
done

loginfo "done"

if [ ${USE_KRB5} -eq 1 ]; then
    loginfo "Adding user to KDC"

    kadmin.local -q "addprinc -clearpolicy -x dn=\"uid=${U_ID},ou=People,${LDAP_BASE}\" -pw ${PASSWORD} ${U_ID}"

    loginfo "done"
fi
