#!/bin/bash
# 2020051701, dury

export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}"

# PWA_CPES used (2)
if   [ ! -z "${PWA_CPES}" ]; then
  export G1_USER=`pwa -D ${PWA_CPES}|awk -F: '{print $2}'`
  sshpass -p `pwa -D ${PWA_CPES}|awk -F: '{print $3}'` \
  ssh -tt -o PubKeyAuthentication=no -l ${G1_USER} ${DEVIP}

# G1_USER and G1_PASS used (1)
elif [ ! -z "${G1_PASS}" ]; then
  if [ -z "${G1_USER}" ]; then
    echo "#- use command '. prepare.sh' first !"
    return
    exit
  fi
  sshpass -p ${G1_PASS} ssh -l ${G1_USER} -o PubkeyAuthentication=no ${DEVIP}

# nothing of above used
else
  if [ -z "${G1_USER}" ]; then
    echo "#- use command '. prepare.sh -c'  first !"
    return
    exit
  fi
  ssh -l ${G1_USER} -o PubkeyAuthentication=no ${DEVIP}
fi

# --- end ---
