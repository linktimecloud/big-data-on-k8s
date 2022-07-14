function checkVar()
{
    local passed=1
    for (( i=1; i<=$#; i++))
    {
        eval varName='$'$i
        if [[ "${!varName}" == "" ]]; then
            echo "[Error] $varName is required but empty."
            passed=0
        fi
    }
    if [[ "$passed" == "0" ]]; then
        exit 1;
    fi
}