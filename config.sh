#  ------------ Align with Vagrantfile ------------ 
export DOMAIN=poc.acme.localdomain   # CAUTION: Edit it, but don't rename or remove it (it is parsed in Vagrantfile) !
export IP_PREFIX=192.168.56          # CAUTION: Edit it, but don't rename or remove it (it is parsed in Vagrantfile) !
export SERVER_SUFFIX=10              # CAUTION: Edit it, but don't rename or remove it (it is parsed in Vagrantfile) !

# ------------ Common settings ------------
export REPO_PATH=$(pwd)
export USE_KRB5=0                    # Edit KRB5 section below, if set to 1

# ------------ LDAP ------------
export LDAP_ORG="Acme AG"
export LDAP_NAME="authx.${DOMAIN}"
export LDAP_IP=${IP_PREFIX}.${SERVER_SUFFIX}
IFS='.' read -r -a PARTS <<< "$DOMAIN"
export BASE=$(printf ",dc=%s" "${PARTS[@]}"  | cut -c2-)
export LDAP_ADMIN="cn=admin,${BASE}"
export LDAP_PASSWORD="ldapsecret"

export LDAP_CERT_EXPIRY=3650
export LDAP_CERT_CN="Bernhard Walter"
export LDAP_CERT_BITS=1024

# ------------ Users and groups ------------
DEFAULT_ADMIN_GROUP="admins"
DEFAULT_GROUP="staff"
GROUP1="all%20users"
GROUP2="acme_users"
GROUP3="acme_admins"
DEFAULT_PW="secret"
export USER_GROUPS="${DEFAULT_ADMIN_GROUP}:10000 ${DEFAULT_GROUP}:10020 ${GROUP1}:10040 ${GROUP2}:10060 ${GROUP3}:10080"
# Format of a user: uid-number:uid:fname:sname:password:group_names
USERS="10000:admin:Admin:Admin:${DEFAULT_PW}:${DEFAULT_ADMIN_GROUP},${GROUP1},${GROUP3}"
USERS="10001:alice:Alice:Amber:${DEFAULT_PW}:${DEFAULT_GROUP},${GROUP1},${GROUP2} $USERS"
USERS="10002:bob:Bob:Black:${DEFAULT_PW}:${DEFAULT_GROUP},${GROUP1},${GROUP2} $USERS"
USERS="10003:mallory:Mallory:Mint:${DEFAULT_PW}:${DEFAULT_GROUP},${GROUP1},${GROUP2} $USERS"
export USERS

# ------------ KRB5 ------------
if [ $USE_KRB5 -eq 1 ]; then
    export KDC_NAME="authx.${DOMAIN}"
    export KDC_IP=${IP_PREFIX}.${SERVER_SUFFIX}
    export REALM=$(echo "$DOMAIN" | tr '[:lower:]' '[:upper:]')
    export KDC_ADMIN="admin"
    export KDC_PASSWORD="krb5secret"
    export KDC_MASTER_KEY="mastersecret"
fi

# ------------ Coloured log outout ------------
ESC=$'\033'
YELLOW="${ESC}[1;33m"
GREEN="${ESC}[1;32m"
RED="${ESC}[1;31m"
NC="${ESC}[0m"

function loginfo {
    echo -e "${YELLOW} >>>>> $@${NC}"
}
