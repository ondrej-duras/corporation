
if [ "$0" != "-bash" ]; then
 echo "run: . prepare.sh"
 exit
fi

## older method ... works also :-) (1)
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

# newer method ... encrypts credentials by session data (2)
export PWA_USER=`pwa -u user -L -P -pwa -nowr`


