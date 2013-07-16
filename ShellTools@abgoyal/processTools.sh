#! /bin/bash

APPLETDIR="$1"
SHELLTOOLS_DT=$2

TOOLSFILE_IN="${APPLETDIR}/tools.ini"
TOOLSFILE_OUT="${APPLETDIR}/tools.json"
TOOLSDIR="${APPLETDIR}/tools/"
STATEFILE="${APPLETDIR}/state.sh"

# client scripts in tools folder take priority
PATH=$TOOLSDIR:$PATH

# state storage for client scripts
# This provides an easy way for a client script to persist state between calls. 
declare -A clickcmd_state
declare -A clickcmd_notifystate
declare -A labelcmd_state
declare -A labelcmd_notifystate

#load states from previous run
if [ -e $STATEFILE ]
then
    source $STATEFILE
fi


echo "[" > "${TOOLSFILE_OUT}.tmp"

while read line
do
    if [[ "$line" =~ ^BEGINITEM:(.+)$ ]]
    then
        state_name="${BASH_REMATCH[1]}"    

        LABELCMD=
        LABELTXT=
        CLICKCMD=
        CLICKTXT=
        NOTIFYCMD=

        while read line
        do
            if [[ "$line" =~ ^END$ ]]
            then
                break
            fi
        
            if [[ $line =~ ^([^=]+)=(.+)$ ]]
            then
                eval "${BASH_REMATCH[1]}"="${BASH_REMATCH[2]}"
            fi
        done

        if [[ "${state_name}" == "SEPERATOR" ]]
        then
            LABELTXT="-"            
        else
            if [[ -n "$LABELCMD" ]] 
            then
                IFS=$'\n'

                cmdoutput=($(export SHELLTOOLS_STATE=${labelcmd_state[${state_name}]} ; export SHELLTOOLS_DT=${SHELLTOOLS_DT} ;  eval ${LABELCMD}))

                # if the client script only generates *exactly* one line of output, use its output as state and notify_state
                if [ ${#cmdoutput[@]} -eq 1 ]
                then
                    new_notifystate="${cmdoutput[0]}"
                    new_state="${cmdoutput[0]}"
                    new_text=${cmdoutput[0]}
                # if the client script generates exactly two lines of output, use first line as state and notify state, and the second as output 
                elif [ ${#cmdoutput[@]} -eq 2 ]
                then
                    new_notifystate="${cmdoutput[0]}"
                    new_state="${cmdoutput[0]}"
                    new_text=${cmdoutput[1]}
                else 
                    # the client script generates more than two line of output.
                    # the first line is notify state, the second line is internal state, third is replacement text, rest is ignored
                    new_notifystate="${cmdoutput[0]}"
                    new_state="${cmdoutput[1]}"
                    new_text=${cmdoutput[2]}
                fi

                # if client script uses notify functionality
                if [[ -n "$NOTIFYCMD" ]]
                then
                    # if notify_state has changed
                    if [ "${labelcmd_notifystate[${state_name}]}" != "${new_notifystate}" ]
                    then
                        # run the notify command
                        (export SHELLTOOLS_NOTIFYSTATE_OLD=${labelcmd_notifystate[${state_name}]} ; export SHELLTOOLS_NOTIFYSTATE=${new_notifystate} ; eval ${NOTIFYCMD} )
                    fi
                fi

                # save new context
                labelcmd_state[${state_name}]=${new_state}
                labelcmd_notifystate[${state_name}]=${new_notifystate}

                LABELTXT=${new_text}

            fi

            if [[ -n "$CLICKCMD" ]] 
            then
                IFS=$'\n'

                cmdoutput=($(export SHELLTOOLS_STATE=${clickcmd_state[${state_name}]} ; export SHELLTOOLS_DT=${SHELLTOOLS_DT} ;  eval ${CLICKCMD}))

                # if the client script only generates *exactly* one line of output, use its output as state and notify_state
                if [ ${#cmdoutput[@]} -eq 1 ]
                then
                    new_notifystate="${cmdoutput[0]}"
                    new_state="${cmdoutput[0]}"
                    new_text=${cmdoutput[0]}
                # if the client script generates exactly two lines of output, use first line as state and notify state, and the second as output 
                elif [ ${#cmdoutput[@]} -eq 2 ]
                then
                    new_notifystate="${cmdoutput[0]}"
                    new_state="${cmdoutput[0]}"
                    new_text=${cmdoutput[1]}
                else 
                    # the client script generates more than two line of output.
                    # the first line is notify state, the second line is internal state, third is replacement text, rest is ignored
                    new_notifystate="${cmdoutput[0]}"
                    new_state="${cmdoutput[1]}"
                    new_text=${cmdoutput[2]}
                fi

                # if client script uses notify functionality
                if [[ -n "$NOTIFYCMD" ]]
                then
                    # if notify_state has changed
                    if [ "${clickcmd_notifystate[${state_name}]}" != "${new_notifystate}" ]
                    then
                        # run the notify command
                        (export SHELLTOOLS_NOTIFYSTATE_OLD=${clickcmd_notifystate[${state_name}]} ; export SHELLTOOLS_NOTIFYSTATE=${new_notifystate} ; eval ${NOTIFYCMD} )
                    fi
                fi

                # save new context
                clickcmd_state[${state_name}]=${new_state}
                clickcmd_notifystate[${state_name}]=${new_notifystate}

                CLICKTXT=${new_text}
            fi
        fi

        # output the popup contents
        echo "[ \"${LABELTXT}\" , \"${CLICKTXT}\" ],"

    fi
done < "$TOOLSFILE_IN" >> "${TOOLSFILE_OUT}.tmp"

echo "]" >> "${TOOLSFILE_OUT}.tmp"

mv "${TOOLSFILE_OUT}.tmp" "${TOOLSFILE_OUT}"

#save states

for i in "${!labelcmd_state[@]}"
do
  echo "labelcmd_state[$i]=\"${labelcmd_state[$i]}\""
done > $STATEFILE

for i in "${!labelcmd_notifystate[@]}"
do
  echo "labelcmd_notifystate[$i]=\"${labelcmd_notifystate[$i]}\""
done >> $STATEFILE

for i in "${!clickcmd_state[@]}"
do
  echo "clickcmd_state[$i]=\"${clickcmd_state[$i]}\""
done >> $STATEFILE

for i in "${!clickcmd_notifystate[@]}"
do
  echo "clickcmd_notifystate[$i]=\"${clickcmd_notifystate[$i]}\""
done >> $STATEFILE

