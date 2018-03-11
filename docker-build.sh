#!/bin/bash
source ./config.sh && source ./lib.sh

VERSION=$1
if [ "x$1" == "x" ]; then
    echo "Usage: $(basename $0) <version> # e.g. 1.0.0"
    exit 1
fi

if [ ${USE_KRB5} -eq 1 ]; then
    NAME="ldap-kdc"
    KRB5_PORTS="-p 464:464 -p 749:749"
else
    NAME="ldap"
    KRB5_PORTS=""
fi
IMAGE="${NAME}-${DOMAIN}"

rm -fr ./target/*
mkdir -p ./target

loginfo "Building docker image ..."
tar -zcf installer.tar.gz bin/ server/ lib.sh config.sh create-server.sh
docker build -t ${IMAGE}:${VERSION} .
rm installer.tar.gz

loginfo "Saving docker image ${IMAGE}:${VERSION} ..."
docker save -o ./target/${IMAGE}-${VERSION}.docker ${IMAGE}:${VERSION} 

loginfo "Extracting CA certificate from docker images ..."
docker rm -f ldap-build 2> /dev/null
docker run -d --name ldap-build ${IMAGE}:${VERSION} 
docker cp ldap-build:/etc/ssl/certs/cacert.pem .
docker rm -f ldap-build

loginfo "Creating client installer archive client-installer.tgz ..."
tar -czf ./target/client-installer.tgz cacert.pem create-client.sh config.sh lib.sh client/

cd target

loginfo "Creating server archive server.tar.bz2 ..."
cat << EOF > ./run.sh
#!/bin/bash
docker load -i ${IMAGE}-${VERSION}.docker
docker run -d -p 88:88 -p 389:389 -p 636:636 ${KRB5_PORTS} -p 8389:8389 --name ${NAME} ${IMAGE}:${VERSION}
EOF
chmod a+x ./run.sh

tar -jcf server.tar.bz2 ${IMAGE}-${VERSION}.docker run.sh

rm ${IMAGE}-${VERSION}.docker run.sh

loginfo "Results in ./target:"
ls -lh
