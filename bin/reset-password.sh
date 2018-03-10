#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

if [ "x$1" == "x" ]; then
    echo "Usage: $(basename $0)" '<uid>'
    exit 1
fi

U_ID=$1

read -p "New password: " -s PASSWORD
echo
read -p "Repeat new password: " -s PASSWORD2
echo
if [ "x$PASSWORD" == "x$PASSWORD2" ]; then
    loginfo "Resetting password for '${U_ID}' in LDAP:"
    SHA_PASSWORD=$(slappasswd -s ${PASSWORD})
    cat > ./group.ldif << EOF
dn: uid=${U_ID},ou=People,${BASE}
changetype: modify
replace: userPassword
userPassword: ${SHA_PASSWORD}
EOF
    ldapmodify -x -D ${LDAP_ADMIN} -w ${LDAP_PASSWORD} -f ./group.ldif
    rm -f ./group.ldif

    if [ ${USE_KRB5} -eq 1 ]; then
        loginfo "Resetting password for '${U_ID}' in KDC"

        kadmin.local -q "change_password -pw ${PASSWORD} ${U_ID}"

        loginfo "done"
    fi
else
    echo "Passwords do not match"
fi

loginfo "done\n"
