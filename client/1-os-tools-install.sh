#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh" && source "$DIR/../lib.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.1 Speeding up yum cache"
yum makecache fast
loginfo "... done\n"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "1.2 Installing OS tools"
yum install -y ntp ntpdate rng-tools
loginfo "... done\n"
