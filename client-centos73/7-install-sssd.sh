#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "7 Installing SSSD"

yum install -y sssd sssd-tools

loginfo "done\n"
