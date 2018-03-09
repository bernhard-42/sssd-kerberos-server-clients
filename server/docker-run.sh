#!/bin/bash

echo "Starting OpenLDAP ..."
service slapd start

echo "Starting PHPLDAPAdmin ..."
apachectl start

echo "Starting kdc ..."
service krb5-kdc start

echo "Starting kadmin ..."
service krb5-admin-server start

sleep infinity
