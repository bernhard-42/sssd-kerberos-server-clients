#!/bin/bash
DIR=$(dirname $0) && source "$DIR/config.sh"

${REPO_PATH}/server/1-os-tools-install.sh
${REPO_PATH}/server/2-os-tools-configure.sh
${REPO_PATH}/server/3-openldap-install.sh
${REPO_PATH}/server/4-openldap-configure.sh
${REPO_PATH}/server/5-openldap-enable-tls.sh
if [ ${USE_KRB5} -eq 1 ]; then
    ${REPO_PATH}/server/6-krb5-install.sh
    ${REPO_PATH}/server/7-krb5-configure.sh
fi
${REPO_PATH}/server/8-create-users.sh
${REPO_PATH}/server/9-openldap-change-acl.sh
