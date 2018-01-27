#!/bin/bash

/vagrant/server/1-install-os-tools.sh
/vagrant/server/2-configure-os-tools.sh
/vagrant/server/3-install-openldap.sh
/vagrant/server/4-configure-openldap.sh
/vagrant/server/5-install-krb5.sh
/vagrant/server/6-configure-krb5.sh
/vagrant/server/7-create-users.sh
