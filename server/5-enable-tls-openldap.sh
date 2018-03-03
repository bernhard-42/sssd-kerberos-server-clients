#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

# Source: https://help.ubuntu.com/lts/serverguide/openldap-server.html#openldap-tls

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Create a private key for the Certificate Authority"
certtool --generate-privkey > /etc/ssl/private/cakey.pem
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Create the template/file /etc/ssl/ca.info to define the CA"
cat <<EOF > /etc/ssl/ca.info
cn = ${LDAP_CERT_CN}
ca
cert_signing_key
EOF
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Create the self-signed CA certificate"
certtool --generate-self-signed \
         --load-privkey /etc/ssl/private/cakey.pem \
         --template /etc/ssl/ca.info \
         --outfile /etc/ssl/certs/cacert.pem
loginfo "... done\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Einen privaten Schlüssel für den Server erstellen"
certtool --generate-privkey \
         --bits $LDAP_CERT_BITS \
         --outfile /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Erstellen Sie das Server-Zertifikat"
cat <<EOF >/etc/ssl/${LDAP_NAME}.info
organization = ${LDAP_ORG}
cn = ${LDAP_NAME}
tls_www_server
encryption_key
signing_key
expiration_days = $LDAP_CERT_EXPIRY
EOF

certtool --generate-certificate \
         --load-privkey /etc/ssl/private/${LDAP_NAME}_slapd_key.pem \
         --load-ca-certificate /etc/ssl/certs/cacert.pem \
         --load-ca-privkey /etc/ssl/private/cakey.pem \
         --template /etc/ssl/${LDAP_NAME}.info \
         --outfile /etc/ssl/certs/${LDAP_NAME}_slapd_cert.pem
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Adjust permissions and ownership"
chgrp openldap /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
chmod 0640 /etc/ssl/private/${LDAP_NAME}_slapd_key.pem
gpasswd -a openldap ssl-cert
loginfo "... done\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Restart slapd"
systemctl restart slapd
sleep 2
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Adding certificates to LDAP"
cat <<EOF > certinfo.ldif
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

ldapmodify -Y EXTERNAL -H ldapi:/// -f certinfo.ldif
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "Enabling ldaps://"
sed -i 's|SLAPD_SERVICES=.*|SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"|' /etc/default/slapd
sed -i 's|TLS_CACERT.*|TLS_CACERT /etc/ssl/certs/cacert.pem|' /etc/ldap/ldap.conf
systemctl restart slapd
loginfo "... done\n"
