#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.1 Validating /etc/hosts"

loginfo "hostname: $(hostname -f) / $(hostname) / $(hostname -i)"
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.2 Validating entropy"

loginfo "Validation"
loginfo "entropy: $(cat /proc/sys/kernel/random/entropy_avail)"
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "2.3 Validating time and ntpd"
timedatectl set-timezone Europe/Berlin

loginfo "Validation"
loginfo "date: $(date)"
loginfo "... done\n"
