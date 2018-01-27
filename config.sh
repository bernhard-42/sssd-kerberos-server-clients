# Align with Vagrantfile
export ORG=acme             # CAUTION: PARSED IN VAGRANTFILE - EDIT IT, BUT DON'T RENAME OR REMOVE !!!
export TLD=localdomain      # CAUTION: PARSED IN VAGRANTFILE - EDIT IT, BUT DON'T RENAME OR REMOVE !!!
export IP_PREFIX=192.168.56 # CAUTION: PARSED IN VAGRANTFILE - EDIT IT, BUT DON'T RENAME OR REMOVE !!!
export SERVER_SUFFIX=10     # CAUTION: PARSED IN VAGRANTFILE - EDIT IT, BUT DON'T RENAME OR REMOVE !!!
export DOMAIN=${ORG}.${TLD}

# LDAP
export LDAP_NAME="authx.${DOMAIN}"
export LDAP_IP=${IP_PREFIX}.${SERVER_SUFFIX}
export BASE="dc=${ORG},dc=${TLD}"
export LDAP_ADMIN="cn=admin,${BASE}"
export LDAP_PASSWORD="ldapsecret"

export USER_GROUPS="admins:10000 staff:10020 all%20users:10040 acme%20users:10060 acme%20admins:10080"
# USER = uid-number:uid:fname:sname:password:group_names
USERS="10000:admin:Admin:Admin:secret:admins,all%20users,acme%20admins"
USERS="10001:alice:Alice:Amber:secret:staff,all%20users,acme%20users $USERS"
USERS="10002:bob:Bob:Black:secret:staff,all%20users,acme%20users $USERS"
USERS="10003:mallory:Mallory:Mint:secret:staff,all%20users,acme%20users $USERS"
export USERS

# KRB5
export KDC_NAME="authx.${DOMAIN}"
export KDC_IP=${IP_PREFIX}.${SERVER_SUFFIX}
export REALM=$(echo "$DOMAIN" | tr '[:lower:]' '[:upper:]')
export KDC_ADMIN="admin"
export KDC_PASSWORD="krb5secret"
export KDC_MASTER_KEY="mastersecret"

function loginfo {
    YELLOW='\e[1;33m'
    NC='\e[0m'
    echo -e "${YELLOW} >>>>> $@${NC}"
}
