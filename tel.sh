#!/bin/bash

export DEVIP=$1
export PUTTY=`echo $SSH_TTY|sed 's/[^0-9]//g'`
printf "\033]0;[%s] %s\007" "${PUTTY}" "${DEVIP}"
telnet ${DEVIP}


