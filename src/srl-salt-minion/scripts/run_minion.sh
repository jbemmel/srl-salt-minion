#!/bin/bash
###########################################################################
# Description:
#     This script will launch the Salt Minion in a venv
###########################################################################


_term (){
    echo "Caugth signal SIGTERM !! "
    kill -TERM "$child" 2>/dev/null
}

function main()
{
    trap _term SIGTERM
    local virtual_env="/opt/srl-salt-minion/.venv/bin/activate"
    local main_module="/usr/bin/salt-minion -d"

    # source the virtual-environment, which is used to ensure the correct python packages are installed,
    # and the correct python version is used
    source "${virtual_env}"

    # ip netns exec srbase-mgmt python3 ${main_module} &
    python3 ${main_module} &

    child=$!
    wait "$child"
}

main "$@"
