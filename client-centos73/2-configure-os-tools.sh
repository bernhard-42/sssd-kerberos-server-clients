#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.1 Setting /etc/hosts"

loginfo "Validation"
loginfo "hostname: $(hostname -f) / $(hostname) / $(hostname -i)"
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.2 Setting entropy"

sed -i "s|ExecStart=/sbin/rngd.*|ExecStart=/sbin/rngd -f -r /dev/urandom|" /usr/lib/systemd/system/rngd.service
systemctl daemon-reload
systemctl start rngd

loginfo "Validation"
loginfo "entropy: $(cat /proc/sys/kernel/random/entropy_avail)"
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.3 Setting time and ntpd"
timedatectl set-timezone Europe/Berlin

ntpdate -b pool.ntp.org
systemctl enable ntpd
systemctl start ntpd

loginfo "Validation"
loginfo "date: $(date)"
loginfo "... done\n"


