#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "8.1 Configuring NSS for SSSD"

cat << EOF > /etc/sssd/sssd.conf
[sssd]
config_file_version = 2
services = nss, pam

domains = LDAP

[nss]
filter_groups = root
filter_users = root
entry_cache_nowait_percentage = 75

[pam]
offline_credentials_expiration = 2
offline_failed_login_attempts = 3
offline_failed_login_delay = 5

[domain/LDAP]
id_provider = ldap
; ldap_schema = rfc2307
; ldap_schema = rfc2307bis
ldap_uri = ldap://${LDAP_IP}
ldap_search_base = ${BASE}
enumerate = true
cache_credentials = true
ldap_default_bind_dn = ${LDAP_ADMIN}
ldap_default_authtok = ${LDAP_PASSWORD}
ldap_default_authtok_type = password
ldap_tls_reqcert = never
EOF

if [ ${USE_KRB5} -eq 1 ]; then
    cat << EOF >> /etc/sssd/sssd.conf
auth_provider = krb5
krb5_server = ${KDC_NAME}
krb5_realm = ${REALM}
EOF
else
    cat << EOF >> /etc/sssd/sssd.conf
auth_provider = ldap
EOF
fi


chmod 600 /etc/sssd/sssd.conf

loginfo "done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "8.2 Configuring PAM for SSSD"
if [ ${USE_KRB5} -eq 1 ]; then
    ENABLE_KRB5="--enablekrb5"
else
    ENABLE_KRB5=""
fi

authconfig --enablesssd --enablesssdauth --enablemkhomedir ${ENABLE_KRB5} --update
loginfo "done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "8.3 Restarting SSSD"
systemctl reload sshd
systemctl restart sssd
loginfo "done\n"
