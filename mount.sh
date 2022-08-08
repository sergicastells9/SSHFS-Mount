#!/bin/bash

# Global vars
connect=""
MOUNT="${HOME}/mnt_1"
USER=""
SERVER=""
AFS="/afs/cern.ch/user"
EOS="/eos/user/"
PTH=""
MAX_MOUNTS=2

# Functions
add_mount () {
  num_mnts=$(($(mount | grep -c ${MOUNT}) + 1))
  tmp=$((${#MOUNT} - ${#num_mnts}))
  MOUNT="${MOUNT:0:$((${tmp}-1))}_${num_mnts}"
  if [ $((${num_mnts} - 1)) -lt ${MAX_MOUNTS} ] && [[ ! -d "${MOUNT}" ]]; then
    mkdir ${MOUNT}
  fi
}

check_mount () {
  if [ $(mount | grep -c ${USER}@${SERVER}) -eq 1 ]; then
    echo 0
  else
    add_mount
    echo 1
  fi
}

print_vars () {
  echo "USER: ${USER}"
  echo "SERVER: ${SERVER}"
  echo "PATH: ${PTH}"
}

get_user () {
  echo ""
  echo "Username: "
  read USER
  echo ""
  if [ "${USER}" == "" ]; then
      break
  fi
  if [ "${USER}" != "" ]; then
    echo "Connecting to ${connect}..."
  fi
}

remove_mount () {
  for (( i=1; i<=${MAX_MOUNTS}; i++ )); do
    MOUNT="${MOUNT:0:$(($((${#MOUNT}-1-${#i}))))}_${i}"

    if [ $(mount | grep -c ${MOUNT}) -eq 0 ]; then
      echo "${MOUNT} directory not mounted."
    else
      echo "Unmounting ${MOUNT} directory..." &&
      diskutil unmount force ${MOUNT}
    fi
  done
}

echo "Test"
mount_server () {
  echo ""
  echo "Mounting ${SERVER}..."

  if [ $(check_mount) -eq 1 ]; then
    num_mnts=$(($(mount | grep -c ${MOUNT}) + 1))
    tmp=$((${#MOUNT} - ${#num_mnts}))
    MOUNT="${MOUNT:0:$((${tmp}-1))}_${num_mnts}"

    echo "sshfs ${USER}@${SERVER}:${PTH} ${MOUNT} -o reconnect -o defer_permissions -o volname=\"${USER}@${SERVER}\""
    sshfs ${USER}@${SERVER}:${PTH} ${MOUNT} -o defer_permissions -o volname="${USER}@${SERVER}" &&
    echo "Mounted sucessfully."
  else
    echo "Server ${SERVER} already mounted to ${MOUNT}."
  fi
}

fix () {
  echo "Fixing mount issues..."
  pg=$(pgrep sshfs)
  procs=()

  IFS=" "
  for id in ${pg}; do
    procs+=("${id}")
  done

  for proc in ${procs}; do
    echo "Killing sshfs process ${proc}."
    kill -9 ${proc}
  done

  echo "All sshfs processes killed."
}

# Main Script
echo "Which server do you want to mount?"
select svr in "lxplus" "earth" "UNMOUNT" "FIX"; do
  case $svr in
    lxplus)
      connect="lxplus"
      get_user
      break;;
    earth)
      connect="earth"
      get_user
      break;;
    UNMOUNT)
      connect="UNMOUNT"
      echo ""
      break;;
    FIX)
      connect="FIX"
      echo ""
      break;;
  esac
done

if [ "${connect}" == "lxplus" ]; then
  PTH="${AFS}/${USER:0:1}/${USER}/"
  SERVER="lxplus.cern.ch"
  print_vars
  mount_server
elif [ "${connect}" == "earth" ]; then
  echo "Have you checked your VPN? [y/n]"
  read vpn
  vpn=$(echo $vpn | tr '[:upper:]' '[:lower:]')
  if [ "${vpn}" == "y" ]; then
    PTH="${AFS}/${USER:0:1}/${USER}/"
    SERVER="earth.crc.nd.edu"
    print_vars
    mount_server
  fi
  if [ "$vpn" != "y" ]; then
    echo "Start VPN first!"
  fi
elif [ "${connect}" == "UNMOUNT" ]; then
  remove_mount
elif [ "${connect}" == "FIX" ]; then
  fix
fi
