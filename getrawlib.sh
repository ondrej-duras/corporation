#!/bin/bash

# if [ "$0" <> "-bash" ]; then
#   echo "#- Error: run it by . $0"
#   return
#   exit
# fi

if [ -z "${PWA_USER}" ]; then
  if [ -z "${SSHPASS}" ]; then
    echo "#- Error: missing SSHPASS !"
    return
    exit
  fi
  if [ -z "${SSHUSER}" ]; then
    echo "#- Error: missing SSHUSER !"
    return
    exit
  fi
fi



function xraw_c3750() {
HNAME=$1
#CLASSID=$2
#CMD=$3
#DEVIP=`host ${HNAME} | awk '{print $4}'`
OUTPUT="./${HNAME}-config.txt"
cat <<__COMMAND__ | go ${HNAME} |\
dos2unix > ${OUTPUT}
  terminal length 0
  show startup
  exit
  exit
  exit
__COMMAND__
}



function xraw_nexus() {
HNAME=$1
#CLASSID=$2
#CMD=$3
#DEVIP=`host ${HNAME} | awk '{print $4}'`
OUTPUT="./${HNAME}-config.txt"
cat <<__COMMAND__ | go ${HNAME} |\
dos2unix > ${OUTPUT}
  terminal length 0
  show running
  exit
  exit
  exit
__COMMAND__
}


function xraw_c7k6() {
HNAME=$1
#CLASSID=$2
#CMD=$3
#DEVIP=`host ${HNAME} | awk '{print $4}'`
OUTPUT="./${HNAME}-config.txt"
cat <<__COMMAND__ | go ${HNAME} |\
dos2unix > ${OUTPUT}
  terminal length 0
  show startup
  exit
  exit
  exit
__COMMAND__
}


function xraw_junos() {
HNAME=$1
#CLASSID=$2
#CMD=$3
OUTPUT="./${HNAME}-config.txt"
#DEVIP=`host ${HNAME} | awk '{print $4}'`
cat <<__COMMAND__ | go ${HNAME} |\
dos2unix > ${OUTPUT}
  set cli screen-length 0
  set cli screen-width 0
  show configuration interfaces | display set
  show configuration routing-instances | display set
  exit
  exit
  exit
__COMMAND__
}

echo "xraw_nexus D-001-BB-RS-70"
echo "xraw_junos D-001-BB-FW-50"
echo "xraw_c7k6  N-001-BB-RR-70"


# --- end ---

