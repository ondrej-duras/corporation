#!/bin/bash
# Template for the simple profile based automation
# 20210604, Ing. Ondrej DURAS (dury)
#=vim color desert

# HOSTLIST
SERVERS=(
'amsdc1-n-001 LINUX'
'amsdc1-s-002 WINDOWS'
'amsd2a-x-003 SOLARIS'
)

# DETYPE PROFILEs
LINUX="PROTO=ssh;      USER=SSHUSER; PASS=SSHPASS; CMD=LINUX_CMD"
WINDOWS="PROTO=rdp;    USER=WINUSER; PASS=WINPASS; CMD=WINDOWS_CMD"
SOLARIS="PROTO=telnet; USER=SSHUSER; PASS=SSHPASS; CMD=SOLARIS_CMD"


# REMOTE ACTIONs
LINUX_CMD=$(cat <<__LNX__
  uname -a
  hostname -f
  hostname -i
  ip address list
__LNX__
)

WINDOWS_CMD=$(cat <<__WIN__
  wmic OS GET Version
  wmic OS GET OSType
  wmic OS GET CSName
__WIN__
)

SOLARIS_CMD=$(cat <<__SOL__
  uname -a
  netstat -in
__SOL__
)


function takeAction() {
HNAME=$1
PROFILE=$2

eval "${!PROFILE}"
echo "${!PROFILE}"
echo "Profile ........... ${PROFILE}"
echo "Protocol .......... ${PROTO}"
echo "User (ENV) ........ ${USER}"
echo "Password (ENV) .... ${PASS}"
echo "Remote Action ..... ${CMD}"
echo "Content:"
cat <<__END__
${!CMD}
__END__
}


for ITEM in "${SERVERS[@]}"; do
  takeAction ${ITEM}
done

# --- end ---
