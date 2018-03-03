#!/bin/bash
DIR=$(dirname $0) && source "$DIR/config.sh"

${REPO_PATH}/server/1-install-os-tools.sh
${REPO_PATH}/server/2-configure-os-tools.sh
${REPO_PATH}/server/3-install-openldap.sh
${REPO_PATH}/server/4-configure-openldap.sh
${REPO_PATH}/server/5-enable-tls-openldap.sh
if [ ${USE_KRB5} -eq 1 ]; then
    ${REPO_PATH}/server/6-install-krb5.sh
    ${REPO_PATH}/server/7-configure-krb5.sh
fi
${REPO_PATH}/server/8-create-users.sh
