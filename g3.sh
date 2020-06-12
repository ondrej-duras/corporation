#!/bin/bash
# 2020051701, dury, revision only

export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s WiFi\007" "${PUTTY}" "${DEVIP}"

# PWA_WIFI used (3)
if   [ ! -z "${PWA_WIFI}" ]; then
  export G3_USER=`pwa -D ${PWA_WIFI}|awk -F: '{print $2}'`
  sshpass -p `pwa -D ${PWA_WIFI}|awk -F: '{print $3}'` \
  ssh -tt -o PubKeyAuthentication=no -l ${G3_USER} ${DEVIP}

# G3_USER and G3_PASS used (1)
elif [ ! -z "${G3_PASS}" ]; then
  if [ -z "${G3_USER}" ]; then
    echo "#- use command '. prepare.sh -w' first !"
    return
    exit
  fi
  sshpass -p ${G3_PASS} ssh -l ${G3_USER} -o PubkeyAuthentication=no ${DEVIP}

# nothing of above used
else
  if [ -z "${G3_USER}" ]; then
    echo "#- use command '. prepare.sh -w'  first !"
    return
    exit
  fi
  ssh -l ${G3_USER} -o PubkeyAuthentication=no ${DEVIP}
fi

# --- end ---
