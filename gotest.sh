#!/bin/bash

VERSION=2017.101601 
MANUAL=<<__MANUAL__
NAME: Go Test
FILE: gotest.sh

DESCRIPTION:
  Provides a short test of environment
  readiness for automated task.

DEPENDENCIES:
  go gonew prepare.sh pwa PWA.pm

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: ${VERSION}
__MANUAL__

if [ "$1" == "--update" ]; then
 rm -f ${HOME}/.ssh/.gotest.DATA
fi

if [ `which pwa | grep -c ^no` != "0" ]; then
  echo "PWA ............ missing!"
  LEGACY="yes"
else 
  echo "PWA ............ ok."
  LEGACY="no"
fi

if [ "${LEGACY}" == "no" ]; then
  if [ -z "${PWA_USER}" ]; then
    echo "PWA_USER ....... missing!"
  else
    echo "PWA_USER ....... ok."
    SSHUSER=`pwa -D ${PWA_USER} |awk -F: '{print $2}'`
    SSHPASS=`pwa -D ${PWA_USER} |awk -F: '{print $3}'`
  fi
fi


if [ -z "${SSHUSER}" ]; then
  echo "SSHUSER ........ missing!"
else
  echo "SSHUSER ........ ok."
fi
if [ -z "${SSHPASS}" ]; then
  echo "SSHPASS ........ missing!"
else
  echo "SSHPASS ........ ok."
fi

CREACT=`echo "abc${SSHUSER}${SSHPASS}" | md5sum | sed 's/.\{15\}$//'`
if [ -f "${HOME}/.ssh/.gotest.DATA" ]; then
  CREDIG=`cat ${HOME}/.ssh/.gotest.DATA`
else
  CREDIG=${CREACT}
  echo -n "${CREACT}" > ${HOME}/.ssh/.gotest.DATA
  echo "#: New digest written."
fi


if [ "${CREACT}" == "${CREDIG}" ]; then
  echo "Credentials .... ok."
else
  echo "Credentials .... WRONG! (use $0 --update)"
fi

echo "${CREACT}"

