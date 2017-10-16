#!/bin/bash

export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}"

# PWA_USER used (2)
if   [ ! -z "${PWA_USER}" ]; then
  export SSHUSER=`pwa -D ${PWA_USER}|awk -F: '{print $2}'`
  sshpass -p `pwa -D ${PWA_USER}|awk -F: '{print $3}'` \
  ssh -tt -o PubKeyAuthentication=no -l ${SSHUSER} ${DEVIP}

# SSHUSER and SSHPASS used (1)
elif [ ! -z "${SSHPASS}" ]; then
  if [ -z "${SSHUSER}" ]; then
    echo "#- use command '. prepare.sh' first !"
    return
    exit
  fi
  sshpass -e ssh -l ${SSHUSER} -o PubkeyAuthentication=no ${DEVIP}

# nothing of above used
else
  if [ -z "${SSHUSER}" ]; then
    echo "#- use command '. prepare.sh' first !"
    return
    exit
  fi
  ssh -l ${SSHUSER} -o PubkeyAuthentication=no ${DEVIP}
fi

# --- end ---
