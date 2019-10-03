FROM ubuntu:18.04

ARG DOMAIN
ARG SERVER_NAME
ARG SERVER_IP

ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER=1

USER root

ADD installer.tar.gz /root/

RUN apt-get update && \
    apt-get -y install tzdata iputils-ping nano && \
    cd /root && \
    bash -o errexit ./create-server.sh $DOMAIN $SERVER_IP $SERVER_NAME $DOCKER

CMD /root/server/docker-run.sh
