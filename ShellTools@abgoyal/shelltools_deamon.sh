#! /bin/bash

TOOLSFILE_IN="tools.json.in"
TOOLSFILE_OUT="tools.json"
SHELLTOOLS_DT=10
declare -A ctx
ctx[blah]="blah"

while true
do
    while IFS='~' read -a cmds
    do
        if [ ${#cmds[@]} -gt 1 ]
        then
            IFS=$'\n'
            ctx_name=${cmds[1]}
            cmd_name=${cmds[2]}
            cmdoutput=($(export $ctx_name=${ctx[${ctx_name}]} ; export SHELLTOOLS_DT=${SHELLTOOLS_DT} ; eval ${cmd_name}))

            if [ ${#cmdoutput[@]} -eq 1 ]
            then
                new_ctx=""
                new_text=${cmdoutput[0]}
            else
                new_ctx=${cmdoutput[0]}
                new_text=${cmdoutput[1]}
            fi

            ctx[${ctx_name}]=${new_ctx}
            
            cmds[1]=""
            cmds[2]=${new_text}

        fi
        echo $(printf "%s" "${cmds[@]}")
    done < $TOOLSFILE_IN > $TOOLSFILE_OUT
    sleep $SHELLTOOLS_DT
done

