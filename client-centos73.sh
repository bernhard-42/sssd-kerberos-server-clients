#!/bin/bash
DIR=$(dirname $0) && source "$DIR/config.sh"

${REPO_PATH}/client-centos73/1-install-os-tools.sh
${REPO_PATH}/client-centos73/2-configure-os-tools.sh
if [ ${USE_KRB5} -eq 1 ]; then
    ${REPO_PATH}/client-centos73/3-install-krb5.sh
    ${REPO_PATH}/client-centos73/4-configure-krb5.sh
fi
${REPO_PATH}/client-centos73/5-install-sssd.sh
${REPO_PATH}/client-centos73/6-configure-sssd.sh
