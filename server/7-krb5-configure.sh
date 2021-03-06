#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7.1 Configuring LDAP to work as kerberos backend"

gzip -d /usr/share/doc/krb5-kdc-ldap/kerberos.schema.gz
cp /usr/share/doc/krb5-kdc-ldap/kerberos.schema /etc/ldap/schema/

cat > /tmp/schema_convert.conf << EOF
include /etc/ldap/schema/core.schema
include /etc/ldap/schema/collective.schema
include /etc/ldap/schema/corba.schema
include /etc/ldap/schema/cosine.schema
include /etc/ldap/schema/duaconf.schema
include /etc/ldap/schema/dyngroup.schema
include /etc/ldap/schema/inetorgperson.schema
include /etc/ldap/schema/java.schema
include /etc/ldap/schema/misc.schema
include /etc/ldap/schema/nis.schema
include /etc/ldap/schema/openldap.schema
include /etc/ldap/schema/ppolicy.schema
include /etc/ldap/schema/kerberos.schema
EOF

rm -fr /tmp/ldif_output
mkdir /tmp/ldif_output

slapcat -f /tmp/schema_convert.conf -F /tmp/ldif_output -n0 -s "cn={12}kerberos,cn=schema,cn=config" > /tmp/cn=kerberos.ldif

sed -i "s|dn: cn={12}|dn: cn=|"        /tmp/cn=kerberos.ldif
sed -i "s|cn: {12}|cn: |"              /tmp/cn=kerberos.ldif

sed -i "s|^structuralObjectClass:.*||" /tmp/cn=kerberos.ldif
sed -i "s|^entryUUID:.*||"             /tmp/cn=kerberos.ldif
sed -i "s|^creatorsName:.*||"          /tmp/cn=kerberos.ldif
sed -i "s|^createTimestamp:.*||"       /tmp/cn=kerberos.ldif
sed -i "s|^entryCSN:.*||"              /tmp/cn=kerberos.ldif
sed -i "s|^modifiersName:.*||"         /tmp/cn=kerberos.ldif
sed -i "s|^modifyTimestamp:.*||"       /tmp/cn=kerberos.ldif

ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /tmp/cn\=kerberos.ldif

cat > /tmp/modify.ldif << EOF
dn: olcDatabase={1}mdb,cn=config
add: olcDbIndex
olcDbIndex: krbPrincipalName eq,pres,sub
EOF

ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /tmp/modify.ldif

cat > /tmp/modify.ldif << EOF
dn: olcDatabase={1}mdb,cn=config
replace: olcAccess
olcAccess: to attrs=userPassword,shadowLastChange,krbPrincipalKey by dn="cn=admin,${LDAP_BASE}" write by anonymous auth by self write by * none
-
add: olcAccess
olcAccess: to dn.base="" by * read
-
add: olcAccess
olcAccess: to * by dn="cn=admin,${LDAP_BASE}" write by * read

EOF

ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /tmp/modify.ldif

loginfo "done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7.2 Creating krb5.conf"

cat > /etc/krb5.conf << EOF
[libdefaults]
    default_realm = ${REALM}
    kdc_timesync = 1
    ccache_type = 4
    forwardable = true
    proxiable = true

[logging]
        kdc = FILE:/var/log/krb5/krb5kdc.log
        admin_server = FILE:/var/log/krb5/kadmind.log
        default = SYSLOG:NOTICE:DAEMON

[realms]
    ${REALM} = {
        kdc = ${KDC_IP}
        admin_server = ${KDC_IP}
        database_module = openldap_ldapconf
    }

[domain_realm]
    ${DOMAIN} = ${REALM}
    .${DOMAIN} = ${REALM}


[dbdefaults]
        ldap_kerberos_container_dn = cn=krbContainer,${LDAP_BASE}


[dbmodules]
    openldap_ldapconf = {
        db_library = kldap
        ldap_kdc_dn = "cn=admin,${LDAP_BASE}"

        # this object needs to have read rights on
        # the realm container, principal container and realm sub-trees
        ldap_kadmind_dn = "cn=admin,${LDAP_BASE}"

        # this object needs to have read and write rights on
        # the realm container, principal container and realm sub-trees
        ldap_service_password_file = /etc/krb5kdc/service.keyfile
        # ldap_servers = ldap://${LDAP_IP}
        ldap_servers = ldap://localhost
        ldap_conns_per_server = 5
    }
EOF

loginfo "done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7.3 Creating REALM"

kdb5_ldap_util -D ${LDAP_ADMIN} create -subtrees ${LDAP_BASE} -r ${REALM} -s -H ldap:/// << EOF
${LDAP_PASSWORD}
${KDC_MASTER_KEY}
${KDC_MASTER_KEY}
EOF


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7.4 Creating stash"

kdb5_ldap_util -D ${LDAP_ADMIN} stashsrvpw -f /etc/krb5kdc/service.keyfile cn=admin,${LDAP_BASE} << EOF
${LDAP_PASSWORD}
${LDAP_PASSWORD}
${LDAP_PASSWORD}
EOF

loginfo "done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7.5 Restarting KDC"

mkdir -p /var/log/krb5/
chmod 700 /var/log/krb5/
sed "/^ReadWriteDirectories/ s|$| /var/log/krb5|" /lib/systemd/system/krb5-kdc.service > /etc/systemd/system/krb5-kdc.service
sed "/^ReadWriteDirectories/ s|$| /var/log/krb5|" /lib/systemd/system/krb5-admin-server.service > /etc/systemd/system/krb5-admin-server.service

restart_service krb5-kdc -r
restart_service krb5-admin-server -r
loginfo "done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7.6 Creating KDC admin user"

kadmin.local -q "addprinc -clearpolicy -pw ${KDC_PASSWORD} ${KDC_ADMIN}/admin@${REALM}"
echo "*/admin@${REALM}    *" > /etc/krb5kdc/kadm5.acl
chmod 644 /etc/krb5kdc/kadm5.acl
loginfo "done\n"
