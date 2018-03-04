# ------------ Coloured log outout ------------
ESC=$'\033'
YELLOW="${ESC}[1;33m"
GREEN="${ESC}[1;32m"
RED="${ESC}[1;31m"
NC="${ESC}[0m"

function loginfo {
    echo -e "${YELLOW} >>>>> $@${NC}"
}

function logerror {
    echo -e "${RED} >>>>> $@${NC}"
}

