#!/bin/bash
# TEMPLATE for the Simplified Network Automation via SSH
# 20210521, Ing. Ondrej DURAS (dury) GPLv2
# VERSION=2021.060301 example for Nexus9K platforms

## HostList ########################################################### {{{ 1

export FILE="MAIL_ME_THIS.txt"
HOSTLIST=(
# GiT-HostList in memory of SHELL classic datacenters
# none of following switches does exist today
'NLAMSDC1MP050 NEXUS' 'NLAMSDC1MP051 NEXUS'
'NLAMSDC2MP050 NEXUS' 'NLAMSDC2MP051 NEXUS'
'NLAMSD2AMP050 NEXUS' 'NLAMSD2AMP051 NEXUS'
'USHOUICMP050  NEXUS' 'USHOUICMP051  NEXUS'
'USMONTSWMP050 NEXUS' 'USMONTSWMP051 NEXUS'
'SYDAMDMRMP998 NEXUS' 'USHOUHDCMP030 NEXUS'

)


####################################################################### }}} 1
## ACTIONs ############################################################ {{{ 1

NEXUS=$(cat <<__END__
terminal length 0
show int status | sed s/^/IF_STATUS;/
show int description | sed s/^/IF_DESC;/
show vrf | include ^[A-Z] | sed s/^/VRF;/
exit
exit
exit
__END__
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
## sshAction ########################################################## {{{ 1

# work with ssh with the output to raw or TSIF output file
function sshAction() {

# parameters (Hostname only for now)
HNAME=$1
ACTION=$2
# Handling SSH session
SSHCMD="sshpass -e ssh -tt"
SSHCMD="${SSHCMD} -o PubKeyAuthentication=no"
SSHCMD="${SSHCMD} -o StrictHostKeyChecking=no"
SSHCMD="${SSHCMD} -l ${SSHUSER} ${HNAME} "
export SSHCMD

# SAFETY BREAK - intended for the write mode of operation
# these few following lines are strongly proposed 
# to be used with "configuration terminal" in action
echo -e "sshAction \033[1;32m${ACTION}\033[m on Hostname \033[1;33m${HNAME}\033[m"
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
#cat <<__COMMAND__ | ${SSHCMD} | sed "s/^/${HNAME};${ACTION};/" | dos2unix | tee -a ${FILE} # Extended TSIF
cat <<__COMMAND__ | ${SSHCMD} | sed "s/^/${HNAME};${ACTION};/" | dos2unix | tee -a ${FILE}
${!ACTION}
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

# SunOS related -adds path for sshpass
#if [ "${HOSTTYPE}" == "sparc" ]; then 
if [ -d "/opt/csw/bin" ]; then
  echo "Extra folder /opt/csw/bin"
fi


# Output file initiation
date +"# Date and Time %Y-%m-%d_%H:%M:%S (%s)" >${FILE}
cat ${FILE}

# checking credentials /asking for them if necessary
credentials

# whole action with host by host
for ITEM in "${HOSTLIST[@]}"
do
  sshAction ${ITEM}
done
echo "Output has been written into '${FILE}'"
echo "done."

####################################################################### }}} 1
# --- end ---

