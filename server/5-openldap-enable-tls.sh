#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

# Source: https://help.ubuntu.com/lts/serverguide/openldap-server.html#openldap-tls

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.1 Create a private key for the Certificate Authority"
certtool --stdout-info \
         --generate-privkey > /etc/ssl/private/cakey.pem
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.2 Create the template/file /etc/ssl/ca.info to define the CA"
cat <<EOF > /etc/ssl/ca.info
cn = ${LDAP_CERT_CN}
ca
cert_signing_key
expiration_days = $LDAP_CERT_EXPIRY
EOF
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.3 Create the self-signed CA certificate"
certtool --stdout-info \
         --generate-self-signed \
         --load-privkey /etc/ssl/private/cakey.pem \
         --template /etc/ssl/ca.info \
         --outfile /etc/ssl/certs/cacert.pem
loginfo "... done\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.4 Creat a private server key"
certtool --stdout-info \
         --generate-privkey \
         --sec-param medium \
         --outfile /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.5 Create server certificate"
cat <<EOF >/etc/ssl/${LDAP_NAME}.info
organization = ${LDAP_ORG}
cn = ${LDAP_NAME}
tls_www_server
encryption_key
signing_key
expiration_days = $LDAP_CERT_EXPIRY
EOF

certtool --stdout-info \
         --generate-certificate \
         --load-privkey /etc/ssl/private/${LDAP_NAME}_slapd_key.pem \
         --load-ca-certificate /etc/ssl/certs/cacert.pem \
         --load-ca-privkey /etc/ssl/private/cakey.pem \
         --template /etc/ssl/${LDAP_NAME}.info \
         --outfile /etc/ssl/certs/${LDAP_NAME}_slapd_cert.pem
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.6 Adjust permissions and ownership"
chgrp openldap /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
chmod 0640 /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
gpasswd -a openldap ssl-cert
loginfo "... done\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.7 Restart slapd"
if [[ $DOCKER -eq 1 ]]; then
    service slapd stop
    killall slapd         # sometimes doesn't stop
    service slapd start
else
    systemctl restart slapd
fi
sleep 2
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.8 Adding certificates to LDAP"
cat <<EOF > /root/certinfo.ldif
dn: cn=config
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ssl/certs/cacert.pem
-
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/${LDAP_NAME}_slapd_cert.pem
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/certinfo.ldif
rm -f /root/certinfo.ldif
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "5.9 Enabling ldaps://"
sed -i 's|SLAPD_SERVICES=.*|SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"|' /etc/default/slapd
sed -i 's|TLS_CACERT.*|TLS_CACERT /etc/ssl/certs/cacert.pem|' /etc/ldap/ldap.conf
restart_service slapd
loginfo "... done\n"
