#!/bin/bash

export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}"

if [ -z "${SSHUSER}" ]; then
  echo "use command '. prepare.sh' first !"
fi

if [ ! -z "${SSHPASS}" ]; then
  sshpass -e ssh -l ${SSHUSER} -o PubkeyAuthentication=no ${DEVIP}
else
  ssh -l duras -o PubkeyAuthentication=no ${DEVIP}
fi


