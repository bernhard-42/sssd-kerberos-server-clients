FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV DOCKER=1

ADD installer.tar.gz /root/
RUN apt-get update && \
    apt-get -y install tzdata iputils-ping nano && \
    cd /root && ./create-server.sh

CMD /root/server/docker-run.sh