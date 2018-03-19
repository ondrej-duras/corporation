#!/bin/bash

export OUTPUT="PORT_STATUS.txt"

function get_port_stat() {
HNAME=$1
cat <<__COMMANDS__ | go ${HNAME} >> ${OUTPUT}
terminal length 0
show int status
exit
exit
exit
__COMMANDS__
}


function get_all_port_stat() {
export OUTPUT=$1
echo "List of SwitchPorts" > ${OUTPUT}
for DEVICE in SWITCH-A-01 SWITCH-B-01 SWITCH-A-02 SWITCH-B-02 
do 
  get_port_stat ${DEVICE}
done
}



get_all_port_stat PORT_REQUIRED.txt 
while [ 1 ]; do
get_all_port_stat PORT_STATUS.txt
echo -en "\033[1;37;41m"
diff PORT_STATUS.txt PORT_REQUIRED.txt
echo -en "\033[m"
echo ...
sleep 5
done


