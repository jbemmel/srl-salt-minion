#!/bin/bash
###########################################################################
# Description:
#     This script will launch the python script of the srl-salty-minion-agent agent
#     (forwarding any arguments passed to this script).
###########################################################################


_term (){
    echo "Caugth signal SIGTERM !! "
    kill -TERM "$child" 2>/dev/null
}

function main()
{
    trap _term SIGTERM
    local virtual_env="/opt/srl-salt-minion/.venv/bin/activate"
    local main_module="/opt/srl-salt-minion/main.py"

    # since 21.6, import from sdk_protos. SDK needs this path
    SDK="/usr/lib/python3.6/site-packages/sdk_protos"
    export PYTHONPATH="$SDK:$PYTHONPATH"

    # source the virtual-environment, which is used to ensure the correct python packages are installed,
    # and the correct python version is used
    source "${virtual_env}"

    ip netns exec srbase-mgmt python3 ${main_module} &

    child=$!
    wait "$child"
}

main "$@"
