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

function is_ubuntu16 {
    if grep -q ubuntu /etc/os-release; then 
        if grep VERSION_ID /etc/os-release  | grep -q 16; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

function is_centos7 {
    if grep -q rhel /etc/os-release; then 
        if grep VERSION_ID /etc/os-release  | grep -q 7; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi    
}