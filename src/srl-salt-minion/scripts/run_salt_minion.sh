#!/bin/bash
###########################################################################
# Description:
#     This script will launch the Salt minion script 
###########################################################################

function main()
{
    local log_file_level="${1}"
    local virtual_env="/opt/srl-salt-minion/.venv/bin/activate"

    # source the virtual-environment, which is used to ensure the correct python packages are installed,
    # and the correct python version is used
    source "${virtual_env}"

    salt-minion -d --log-file-level=${log_file_level}
    exit $?
}

main "$@"
