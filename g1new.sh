#!/bin/bash
# GO - client script to simplify SSH access


export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}"

# PWA_CPES used (2)
if   [ ! -z "${PWA_CPES}" ]; then
  export G1_USER=`pwa -D ${PWA_CPES}|awk -F: '{print $2}'`
  sshpass -p `pwa -D ${PWA_CPES}|awk -F: '{print $3}'` \
  ssh -tt \
    -o PubKeyAuthentication=no \
    -o StrictHostKeyChecking=no \
    -l ${G1_USER} ${DEVIP} exit

# SSHUSER and SSHPASS used (1)
elif [ ! -z "${SSHPASS}" ]; then
  if [ -z "${SSHUSER}" ]; then
    echo "#- use command '. prepare.sh' first !"
    return
    exit
  fi
  sshpass -e ssh -tt \
    -o PubkeyAuthentication=no \
    -o StrictHostKeyChecking=no \
    -l ${SSHUSER} ${DEVIP} exit

# nothing of above used
else
  if [ -z "${SSHUSER}" ]; then
    echo "#- use command '. prepare.sh' first !"
    return
    exit
  fi
  ssh -tt \
    -o PubkeyAuthentication=no 
    -o StrictHostKeyChecking=no \
    -l ${SSHUSER} ${DEVIP} exit
fi

# --- end ---

