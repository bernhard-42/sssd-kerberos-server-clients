#  ------------ Align with Vagrantfile ------------ 
export DOMAIN=poc.acme.local         # CAUTION: Edit it, but don't rename or remove it (it is parsed in Vagrantfile) !
export SERVER_IP=192.168.56.10       # CAUTION: Edit it, but don't rename or remove it (it is parsed in Vagrantfile) !
export DOCKER=1                      # CAUTION: Edit it, but don't rename or remove it (it is parsed in Vagrantfile) !

export SERVER_NAME=authx

# ------------ Common settings ------------
export TZ=Europe/Berlin
export REPO_PATH=$(pwd)
export USE_KRB5=1                    # Edit KRB5 section below, if set to 1
export PHPLDAPADMIN=1                # Edit PHPLADPADMIN section below, if set to 1

# ------------ LDAP ------------
export LDAP_ORG="Acme AG"
export LDAP_NAME="${SERVER_NAME}.${DOMAIN}"
export LDAP_IP=${SERVER_IP}
IFS='.' read -r -a PARTS <<< "$DOMAIN"
export LDAP_BASE=$(printf ",dc=%s" "${PARTS[@]}"  | cut -c2-)
export LDAP_ADMIN="cn=admin,${LDAP_BASE}"
export LDAP_PASSWORD="ldapsecret"

export LDAP_CERT_EXPIRY=3650
export LDAP_CERT_CN="Bernhard Walter"

# ------------ KRB5 ------------
if [ $USE_KRB5 -eq 1 ]; then
    export KDC_NAME="${SERVER_NAME}.${DOMAIN}"
    export KDC_IP=${SERVER_IP}
    export REALM=$(echo "$DOMAIN" | tr '[:lower:]' '[:upper:]')
    export KDC_ADMIN="admin"
    export KDC_PASSWORD="krb5secret"
    export KDC_MASTER_KEY="mastersecret"
fi

# ------------ phpLADPadmin ------------
if [ $PHPLDAPADMIN -eq 1 ]; then
    export PHPLDAPADMIN_PORT=8389
fi

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

