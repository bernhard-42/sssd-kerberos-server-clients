#!/bin/bash
DIR=$(dirname $0) && source "$DIR/../config.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "8.1 Creating group"

for USER_GROUP in ${USER_GROUPS}; do
    GROUP_ID=${USER_GROUP#*:}
    GROUP_NAME=${USER_GROUP%:*}
    ${DIR}/../bin/create-group.sh "${GROUP_ID}" "${GROUP_NAME}"
done

loginfo "done\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loginfo "8.2 Creating users"

for USR in ${USERS}; do
    # Format of a user: uid-number:uid:fname:sname:password:group_names
    IFS=':' read -r -a ATTR <<< "$USR"
    UID_NUMBER="${ATTR[0]}"
    U_ID="${ATTR[1]}"
    FNAME="${ATTR[2]}"
    SNAME="${ATTR[3]}"
    PASSWORD="${ATTR[4]}"
    GROUP_NAMES="${ATTR[5]}"
    ${DIR}/../bin/create-user.sh "${UID_NUMBER}" "${U_ID}" "${FNAME}" "${SNAME}" "${PASSWORD}" "${GROUP_NAMES}" -m
done

loginfo "done\n"
