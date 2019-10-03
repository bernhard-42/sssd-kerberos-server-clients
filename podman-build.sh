#!/bin/bash

export VERSION=${1:?Usage: $(basename $0) image-version}

source ./config-standalone.sh
source ./config.sh
source ./lib.sh

if [[ ${USE_KRB5} -eq 1 ]]; then
    NAME="ldap-kdc"
    KRB5_PORTS="-p 464:464 -p 749:749"
else
    NAME="ldap"
    KRB5_PORTS=""
fi
if [[ $USE_PHPLDAPADMIN -eq 1 ]]; then
    PHP_PORT="-p 8389:8389"
else
    PHP_PORT=""
fi

IMAGE="${NAME}-${DOMAIN}"

rm -fr ./target/*
mkdir -p ./target

loginfo "Building podman image ..."
tar -zcf installer.tar.gz bin/ server/ lib.sh config-standalone.sh config.sh create-server.sh
podman build --build-arg DOMAIN=${DOMAIN} \
             --build-arg SERVER_IP=${SERVER_IP} \
             --build-arg SERVER_NAME=${SERVER_NAME} \
             -t ${IMAGE}:${VERSION} \
             .
RET=$?
rm -f installer.tar.gz  # clean up
[[ $RET -ne 0 ]] && exit $RET

loginfo "Saving podman image ${IMAGE}:${VERSION} ..."
podman save -o ./target/${IMAGE}-${VERSION}.podman ${IMAGE}:${VERSION}

loginfo "Extracting CA certificate from podman images ..."
podman rm -f ldap-build 2> /dev/null
podman run -d --name ldap-build ${IMAGE}:${VERSION}
podman cp ldap-build:/etc/ssl/certs/cacert.pem .
podman rm -f ldap-build

loginfo "Creating client installer archive client-installer.tgz ..."
tar -czf ./target/client-installer.tgz cacert.pem create-client.sh config-standalone.sh config.sh lib.sh client/

cd target

loginfo "Creating server archive server.tgz ..."
cat << EOF > ./run.sh
#!/bin/bash
podman load -i ${IMAGE}-${VERSION}.docker
podman run -d -p 88:88 -p 389:389 -p 636:636 ${KRB5_PORTS} ${PHP_PORT} --name ${NAME} ${IMAGE}:${VERSION}
EOF
chmod a+x ./run.sh

tar -zcf server.tgz ${IMAGE}-${VERSION}.podman run.sh

rm ${IMAGE}-${VERSION}.podman # run.sh

loginfo "Results in ./target:"
ls -lh
