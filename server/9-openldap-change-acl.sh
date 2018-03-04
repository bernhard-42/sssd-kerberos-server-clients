#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "9 Changing Access Control"
if [ $USE_KRB5 -eq 1 ]; then
    ATTRS="userPassword,shadowLastChange,krbPrincipalKey"
else
    ATTRS="userPassword,shadowLastChange"
fi

cat << EOF > /root/access.ldif
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=${ATTRS}
  by dn="${LDAP_ADMIN}" write
  by anonymous auth
  by self write
  by * none
olcAccess: {1}to dn.base=""
  by * read
olcAccess: {2}to *
  by self write
  by dn="${LDAP_ADMIN}" write
  by users read
  by * auth
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/access.ldif
rm /root/access.ldif
loginfo "... done\n"
