#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.1 Setting /etc/hosts"

loginfo "Validation"
loginfo "hostname: $(hostname -f) / $(hostname) / $(hostname -i)"
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.2 Setting entropy"

if is_centos7; then
    sed -i "s|ExecStart=/sbin/rngd.*|ExecStart=/sbin/rngd -f -r /dev/urandom|" /usr/lib/systemd/system/rngd.service
    systemctl daemon-reload
    systemctl start rngd
elif is_ubuntu16; then
    /etc/init.d/rng-tools start
elif is_sles12; then
    systemctl start rng-tools
else
    logerr "OS not supprted"
fi

loginfo "Validation"
loginfo "entropy: $(cat /proc/sys/kernel/random/entropy_avail)"
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.3 Setting time and ntpd"
timedatectl set-timezone Europe/Berlin

loginfo "Validation"
loginfo "date: $(date)"
loginfo "... done\n"


