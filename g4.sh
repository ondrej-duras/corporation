#!/bin/bash
# 2020051701, dury, revision only

export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s WiFi\007" "${PUTTY}" "${DEVIP}"

# PWA_EXTA used (4)
if   [ ! -z "${PWA_EXTA}" ]; then
  export G4_USER=`pwa -D ${PWA_EXTA}|awk -F: '{print $2}'`
  sshpass -p `pwa -D ${PWA_EXTA}|awk -F: '{print $3}'` \
  ssh -tt -o PubKeyAuthentication=no -l ${G4_USER} ${DEVIP}

# G4_USER and G4_PASS used (4)
elif [ ! -z "${G4_PASS}" ]; then
  if [ -z "${G4_USER}" ]; then
    echo "#- use command '. prepare.sh -e' first !"
    return
    exit
  fi
  sshpass -p ${G4_PASS} ssh -l ${G4_USER} -o PubkeyAuthentication=no ${DEVIP}

# nothing of above used
else
  if [ -z "${G4_USER}" ]; then
    echo "#- use command '. prepare.sh -e'  first !"
    return
    exit
  fi
  ssh -l ${G4_USER} -o PubkeyAuthentication=no ${DEVIP}
fi

# --- end ---
