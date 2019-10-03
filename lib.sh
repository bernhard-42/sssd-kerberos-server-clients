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
    grep -q ubuntu /etc/os-release && grep VERSION_ID /etc/os-release | grep -q 16
    return $?
}

function is_centos7 {
    grep -q rhel /etc/os-release && grep VERSION_ID /etc/os-release | grep -q 7
    return $?
}

function is_sles12 {
    grep -q SLES /etc/os-release && grep VERSION /etc/os-release | grep -q "12-"
    return $?
}

function set_tz {
    local tz="${1:?Parm 1 (TZ) must be set}"

    if [[ ${DOCKER} -eq 1 ]]; then
        ln -snf /usr/share/zoneinfo/${tz} /etc/localtime
        echo ${tz} > /etc/timezone
    else
        timedatectl set-timezone ${tz}
    fi
}

function start_service {
    local service="${1:?Parm 1 (service) must be set}"

    if [[ ${DOCKER} -eq 1 ]]; then
        if [[ "${service}" == apache2 ]]; then
            apachectl start
        else
            service "${service}" start
        fi
    else
        systemctl start "${service}"
    fi
}

function restart_service {
    local service="${1:?Parm 1 (service) must be set}"
    local flag=${2:-""}

    if [[ ${DOCKER} -eq 1 ]]; then
        if [ "${service}" == apache2 ]; then
            apachectl restart
        else
            set +e
            service "${service}" stop
            sleep 1
            pkill "${service}" || echo "nothing to be killed"
            set -e
            service "${service}" start
        fi
    else
        if [[ ${flag} == "-r" ]]; then
            systemctl daemon-reload
        fi
        systemctl restart "${service}"
    fi
}

