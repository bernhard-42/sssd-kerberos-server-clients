#!/bin/bash
set -o errexit ; set -o nounset

DIR=$(dirname $0)

# Add defaults to variables controlling the setup system
VAGRANT=${VAGRANT:-0}
DOCKER=${DOCKER:-0}
export DOCKER

if [[ ${VAGRANT} -eq 1 ]]; then
    USAGE="Usage: $(basename $0)  domain  server-ip  server-name"
    export DOMAIN=${1:?$USAGE}
    export SERVER_IP=${2:?$USAGE}
    export SERVER_NAME=${3:?$USAGE}
    echo "Using vagrant config"
else

    source "${DIR}/config-standalone.sh"
    echo "Using standalone config"
fi

source "${DIR}/config.sh"

# Main

${REPO_PATH}/server/1-os-tools-install.sh
${REPO_PATH}/server/2-os-tools-configure.sh
${REPO_PATH}/server/3-openldap-install.sh
${REPO_PATH}/server/4-openldap-configure.sh
${REPO_PATH}/server/5-openldap-enable-tls.sh
if [[ ${USE_KRB5} -eq 1 ]]; then
    ${REPO_PATH}/server/6-krb5-install.sh
    ${REPO_PATH}/server/7-krb5-configure.sh
fi
${REPO_PATH}/server/8-create-users.sh
${REPO_PATH}/server/9-openldap-change-acl.sh
