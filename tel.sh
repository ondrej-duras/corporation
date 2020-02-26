#!/bin/bash

ARGC=$#
export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
if [ "${ARGC}" -eq "1" ]; then 
  printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}"
  echo "telnet ${DEVIP}"
  telnet ${DEVIP}
elif [ "${ARGC}" -eq "2" ]; then
  printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}:${2}"
  echo "telnet ${DEVIP} ${2}"
  telnet ${DEVIP} $2
else
  echo "Error: provide hostname or hostname and port !"
fi

