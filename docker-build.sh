#!/bin/bash
source ./config.sh

VERSION=$1
if [ "x$1" == "x" ]; then
    echo "Usage: $(basename $0) <version> # e.g. 1.0.0"
    exit 1
fi

if [ ${USE_KRB5} -eq 1 ]; then
    NAME="ldap-kdc"
else
    NAME="ldap"
fi
IMAGE="${NAME}-${DOMAIN}"

tar -zcf installer.tar.gz bin/ server/ lib.sh config.sh create-server.sh
docker build -t ${IMAGE}:${VERSION} .
rm installer.tar.gz

rm -fr ./target/*
mkdir -p ./target

docker run -d --name ldap ${IMAGE}:${VERSION} 
docker cp ldap:/etc/ssl/certs/cacert.pem ./target
docker rm -f ldap

cp config.sh lib.sh ./target/
tar -czf ./target/client-installer.tgz create-client.sh client/

docker save -o ./target/${IMAGE}-${VERSION}.docker ${IMAGE}:${VERSION} 

cat << EOF > ./target/run.sh
#!/bin/bash
docker run -d -p 88:88 -p 389:389 -p 464:464 -p 636:636 -p 749:749 -p 8389:8389 --name ${NAME} ${IMAGE}:${VERSION}
EOF
chmod a+x ./target/run.sh

echo "Results in ./target:"
ls -lh ./target
