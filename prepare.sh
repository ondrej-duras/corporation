
if [ "$0" != "-bash" ]; then
 echo "run: . prepare.sh"
 exit
fi

## older 1st method ... works also :-) (1)
# read -p  "ssh user: " SSHUSER
# read -sp "ssh pas1: " SSHPAS1
# echo "."
# read -sp "ssh pas2: " SSHPAS2
# echo "."
# 
# if [ "${SSHPAS1}" != "${SSHPAS2}" ]; then
#   echo "Password do not match !"
#   return
# fi
# echo "${SSHPAS1}" | md5sum
# export SSHPASS=${SSHPAS1}
# export SSHPASS SSHUSER
# echo "good."

# newer 2nd method ... encrypts credentials by session data (2)
# export PWA_USER=`pwa -u user -L -P -pwa -nowr`
# gotest # to check password
# -P or -P2 proceeds password question 2 times


# newer 3rd method ... encrypts credetials
# question for password is made once only
# then it's checked against half-signature, stored
# in specific file

# gotest continues
##!/bin/bash

VERSION=2017.110701 
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

# here is the question for login and password
if [ -z "${SSHUSER}" ]; then
  export PWA_USER=`pwa -u user -L -P1 -pwa -nowr`
else
  export PWA_USER=`pwa -u user -l ${SSHUSER} -P1 -pwa -nowr`
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
  echo "Credentials .... WRONG! (use . prepare.sh --update)"
fi

unset SSHPASS
# echo "${CREACT}"
# --- end ---


