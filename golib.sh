#!/bin/bash

#if [ "$0" == "-bash" ]; then
#  echo "#- Error: run it by ./$0"
#fi

if [ -z "${PWA_USER}" ]; then
  if [ -z "${SSHPASS}" ]; then
    echo "#- Error: missing SSHPASS !"
    exit
  fi
  if [ -z "${SSHUSER}" ]; then
    echo "#- Error: missing SSHUSER !"
    exit
  fi
fi

#cd 
#mkdir "${HOME}/data"
#cd $HOME/data
#OUTPUT="HINV.csv"

#echo "#DEVIP;HNAME;CLASSID;DATA..." > ${OUTPUT}
OUTPUT="RAW.csv"

function xnexus() {
HNAME=$1
CLASSID=$2
CMD=$3
DEVIP=`host ${HNAME} | awk '{print $4}'`
cat <<__COMMAND__ | go ${HNAME} |\
sed "s/^/${DEVIP};${HNAME};${CLASSID};/" | dos2unix >> ${OUTPUT}
  terminal length 0
  ${CMD}
  exit
  exit
  exit
__COMMAND__
}

function xjunos() {
HNAME=$1
CLASSID=$2
CMD=$3
DEVIP=`host ${HNAME} | awk '{print $4}'`
cat <<__COMMAND__ | go ${HNAME} |\
sed "s/^/${DEVIP};${HNAME};${CLASSID};/" | dos2unix >> ${OUTPUT}
  set cli screen-length 0
  set cli screen-width 0
  ${CMD}
  exit
  exit
  exit
__COMMAND__
}

function xbigip() {
HNAME=$1
CLASSID=$2
CMD=$3
DEVIP=`host ${HNAME} | awk '{print $4}'`
cat <<__COMMAND__ | go ${HNAME} |\
sed "s/^/${DEVIP};${HNAME};${CLASSID};/" | dos2unix >> ${OUTPUT}
  modify cli preference pager disabled
  ${CMD}
  y
  quit
  quit
  quit
__COMMAND__
}

function xios3() {
HNAME=$1
CLASSID=$2
CMD=$3
DEVIP=`host ${HNAME} | awk '{print $4}'`
cat <<__COMMAND__ | go ${HNAME} |\
sed "s/^/${DEVIP};${HNAME};${CLASSID};/" | dos2unix >> ${OUTPUT}
  terminal length 0
  ${CMD}
  exit
  exit
  exit
__COMMAND__
}

#xnexus D-001-BB-RS-70  INV_NX7K "show inventory"
#xjunos D-001-BB-FW-50  INV_SRX3 "show chassis hardware"
#xbigip D-005-BA-ADC-50 INV_F5V0 'show sys hardware | grep -i "name\|serial"'

# --- end ---

