
if [ "$0" != "-bash" ]; then
 echo "run: . prepare.sh --help # for details"
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

#VERSION=2017.110701 
VERSION=2020.022601 
function manual() {
cat <<__MANUAL__
NAME: Prepare Credentials
FILE: . prepare.sh

DESCRIPTION:
  Provides a feeding of credentials into ENVironment.
  Also yu can use it for chcking of credentials before
  you run your scripts.
  Utility depends on PWA.
  PWA is a PassWord Agent. It's a framework for
  very simple protected password authentication.
  PWA decreases a risk of automation passwords disclosure.
  PWA was requested by PCI (Pay Card Infrastructure) certification.


USAGE:
  . prepare --help # for this manual page
  . prepare.sh     # to enter PE credentials
  . prepare.sh -c  # to enter CPE credentials
  . prepare.sh -a  # to enter both PE and CPE credentials
  . prepare.sh -l  # to enter legacy SSHUSER and SSHPASS
  . prepare.sh -a --update # re-enter digest of all credentials
  . prepare.sh -c --update # re-enter digest of CPE credentials only
  . prepare.sh --update    # re-enter digest of PE credentials only
  . prepare.sh --check     # test all credentials
  . prepare.sh --test      # test all credentials


DEPENDENCIES:
  go gonew pwa PWA.pm PWA.py
  g1 g1new

SEE ALSO:
  https://github.com/ondrej-duras/

VERSION: ${VERSION}
__MANUAL__
}

# Hanling command-line parameters
ARG1=$1
ARG2=$2
ENTRY_G0="yes"     # for PE  credentials
ENTRY_G1="no"      # for CPE credentials
ENTRY_UPDATE="no"  # update stored credential digests
ENTRY_MANUAL="no"  # manual page requested
ENTRY_LEGACY="no"  # allows to enter legacy SSHUSER and SSHPASS
ENTRY_CHECKS="no"  # proceed ENV checks for all credentials

if [ "${ARG1}" == "--help" ]; then
  ENTRY_MANUAL="yes"
fi
if [ "${ARG1}" == "--update" ]; then
  ENTRY_UPDATE="yes"
fi
if [ "${ARG2}" == "--update" ]; then
  ENTRY_UPDATE="yes"
fi
if [ "${ARG1}" == "--check" ]; then
  ENTRY_G0="no"
  ENTRY_G1="no"
  ENTRY_LEGACY="no"  # alias for ENTRY_G2
fi
if [ "${ARG1}" == "--test" ]; then
  ENTRY_G0="no"
  ENTRY_G1="no"
  ENTRY_LEGACY="no"  # alias for ENTRY_G2
fi
if [ "${ARG1}" == "-c" ]; then
  ENTRY_G0="no"
  ENTRY_G1="yes"
  ENTRY_LEGACY="no"  # G2
fi
if [ "${ARG1}" == "-a" ]; then
  ENTRY_G0="yes"
  ENTRY_G1="yes"
  ENTRY_LEGACY="no"  # G2
fi
if [ "${ARG1}" == "-l" ]; then
  ENTRY_G0="no"
  ENTRY_G1="no"
  ENTRY_LEGACY="yes" # G2
fi


# Providing standard manual page --help
if [ "${ENTRY_MANUAL}" == "yes" ]; then
  manual
  return
fi

# clearing stored credential digests
if [ "${ENTRY_UPDATE}" == "yes" ]; then
 if [ "${ENTRY_G0}" == "yes" ]; then # PE Credentials
   rm -f ${HOME}/.ssh/.gotest.G0DATA
 fi
 if [ "${ENTRY_G1}" == "yes" ]; then # CPE Credentials
   rm -f ${HOME}/.ssh/.gotest.G1DATA
 fi
fi

# here is the question for login and password
if [ "${ENTRY_G0}" == "yes" ]; then
  if [ -z "${SSHUSER}" ]; then
    export PWA_USER=`pwa -u user -L -P1 -pwa -nowr`
  else
    export PWA_USER=`pwa -u user -l ${SSHUSER} -P1 -pwa -nowr`
  fi
fi

if [ "${ENTRY_G1}" == "yes" ]; then
  if [ -z "${SSHUSER}" ]; then
    export PWA_CPES=`pwa -u cpes -L -P1 -pwa -nowr`
  else
    export PWA_CPES=`pwa -u cpes -l ${SSHUSER} -P1 -pwa -nowr`
  fi
fi

if [ "${ENTRY_LEGACY}" == "yes" ]; then  # alias G2DATA
  if [ -z "${SSHUSER}" ]; then
    read -p "[legacy] Login: " SSHUSER
    export SSHUSER 
  fi
  read -p "[legacy] Password:" SSHPASS
  export SSHPASS
fi


# Checking presence of PWA
if [ `which pwa | grep -c ^no` != "0" ]; then
  echo "PWA ................ missing!"
  LEGACY="yes"
else 
  echo "PWA ................ ok."
  LEGACY="no"
fi

# Checking Legacy Credentials
if [ -z "${SSHUSER}" ]; then
  echo "SSHUSER ............ missing!"
else
  echo "SSHUSER ............ ok."
fi
if [ -z "${SSHPASS}" ]; then
  echo "SSHPASS ............ no."
else
  echo "SSHPASS ............ FOUND!"
fi


if [ "${LEGACY}" == "no" ]; then
  if [ -z "${PWA_USER}" ]; then
    echo "PWA_USER ........... none."
  else
    echo "PWA_USER ........... ok."
    G0_USER=`pwa -D ${PWA_USER} |awk -F: '{print $2}'`
    G0_PASS=`pwa -D ${PWA_USER} |awk -F: '{print $3}'`
  
    G0_CREACT=`echo "abc${G0_USER}${G0_PASS}" | md5sum | sed 's/.\{15\}$//'`
    if [ -f "${HOME}/.ssh/.gotest.G0DATA" ]; then
      G0_CREDIG=`cat ${HOME}/.ssh/.gotest.G0DATA`
    else
      G0_CREDIG=${G0_CREACT}
      echo -n "${G0_CREACT}" > ${HOME}/.ssh/.gotest.G0DATA
      echo "#: New PE digest written."
    fi
  
    if [ "${G0_CREACT}" == "${G0_CREDIG}" ]; then
      echo "PE Credentials ..... ok."
    else
      echo "PE Credentials ..... WRONG! (use . prepare.sh --update)"
    fi
    
    unset G0_USER G0_PASS G0_CREAT G0_CREDIG

  fi

  # ----

  if [ -z "${PWA_CPES}" ]; then
    echo "PWA_CPES ........... none."
  else
    echo "PWA_CPES ........... ok."
    G1_USER=`pwa -D ${PWA_CPES} |awk -F: '{print $2}'`
    G1_PASS=`pwa -D ${PWA_CPES} |awk -F: '{print $3}'`

    G1_CREACT=`echo "xyz${G1_USER}${G1_PASS}" | md5sum | sed 's/.\{15\}$//'`
    if [ -f "${HOME}/.ssh/.gotest.G1DATA" ]; then
      G1_CREDIG=`cat ${HOME}/.ssh/.gotest.G1DATA`
    else
      G1_CREDIG=${G1_CREACT}
      echo -n "${G1_CREACT}" > ${HOME}/.ssh/.gotest.G1DATA
      echo "#: New CPE digest written."
    fi
  
    if [ "${G1_CREACT}" == "${G1_CREDIG}" ]; then
      echo "CPE Credentials .... ok."
    else
      echo "CPE Credentials .... WRONG! (use . prepare.sh --update)"
    fi
    
    unset G1_USER G1_PASS G1_CREAT G1_CREDIG

  fi

fi





# unset SSHPASS
# echo "${CREACT}"
# --- end ---


