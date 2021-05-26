#!/bin/bash
# Powe-On Hours - Check (28224 Hours are in limit)
# 20210521, Ing. Ondrej DURAS (dury) GPLv2
# VERSION=2021.052501 example for Nexus9K platforms

## HostList ########################################################### {{{ 1

export FILE="MAIL_ME_THIS_POH.txt"
HOSTLIST=(
# GiT-HostList in memory of SHELL classic datacenters
# none of following switches does exist today
'NLAMSDC1MP050' 'NLAMSDC1MP051'
'NLAMSDC2MP050' 'NLAMSDC2MP051'
'NLAMSD2AMP050' 'NLAMSD2AMP051'
'USHOUICMP050'  'USHOUICMP051'
'USMONTSWMP050' 'USMONTSWMP051'
'SYDAMDMRMP998' 'USHOUHDCMP030'

)


####################################################################### }}} 1
## Credentials handling ############################################### {{{ 1

# check whether the credetials have been provided
function credentials() {
  if [ -z "${SSHUSER}" ]; then
    read -p  "PE  Login: " SSHUSER
    export SSHUSER
  fi
  while [ -z "${SSHPASS}" ]; do
    read -sp "PE Pwd[1]: " SSHPAS1
    echo "."
    read -sp "PE Pwd[2]: " SSHPAS2
    echo "."
    if [ "${SSHPAS1}" == "${SSHPAS2}" ]; then
       export SSHPASS="${SSHPAS1}"
       echo "password ok."
    else
       echo "Passwords do not match ! Again please..."
    fi
  done    
  echo "File Name: ${FILE}"
  echo "# Login: ${SSHUSER}" >>${FILE}
}

####################################################################### }}} 1
## SSH Action ######################################################### {{{ 1

# work with ssh with the output to raw or TSIF output file
function sshAction() {

# parameters (Hostname only for now)
HNAME=$1

# Handling SSH session
SSHCMD="sshpass -e ssh -tt"
SSHCMD="${SSHCMD} -o PubKeyAuthentication=no"
SSHCMD="${SSHCMD} -o StrictHostKeyChecking=no"
SSHCMD="${SSHCMD} -l ${SSHUSER} ${HNAME} "
export SSHCMD

# SAFETY BREAK - intended for the write mode of operation
# these few following lines are strongly proposed
# to be used with "configuration terminal" in action
echo -e "sshAction with Hostname \033[1;33m${HNAME}\033[m"
read -p "Safety Break ... is it ok (Y=Continue/anything_else=Stop) ?" ANSWER
if [ "${ANSWER}" == "S" ]; then
  echo "Hostname ${HNAME} skipped." | tee -a ${FILE}
  return
fi
if [ "${ANSWER}" != "Y" ]; then
  echo "OK. terminating whole action at ${HNAME}." | tee -a ${FILE}
  exit
fi


# Whole Action itself
#cat <<__COMMAND__ | ${SSHCMD} | dos2unix | tee -a ${FILE}   # RAW output
#cat <<__COMMAND__ | ${SSHCMD} | sed "s/^/${HNAME};/" | dos2unix | tee -a ${FILE} # TSIF output
cat <<__COMMAND__ | ${SSHCMD} | sed "s/^/${HNAME};/" | dos2unix | tee -a ${FILE}
terminal length 0
show version
configure terminal
feature bash
  run bash sudo su
    smartctl -a /dev/sda | egrep 'Model|Firmware|Hours'
  exit
no feature bash
end
exit
exit
exit
__COMMAND__

# housekeeping environment
export SSHCMD=
}

####################################################################### }}} 1
## MAIN Procedure ##################################################### {{{ 1

# requires to be started correctly 
if [ "$0" == "-bash" ]; then
  echo "Error: run it by ./${0}"
  return
  exit
fi

# Output file initiation
date +"# Date and Time %Y-%m-%d_%H:%M:%s" >${FILE}
cat ${FILE}

# checking credentials /asking for them if necessary
credentials

# whole action with host by host
for HOST in "${HOSTLIST[@]}"
do
  sshAction ${HOST}
done
echo "done."
echo "Please send whole file ${FILE} to anything@anything.com"
echo "Thanks a lot."

####################################################################### }}} 1
# --- end ---

