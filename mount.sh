#!/bin/bash

connect=""
USER=""
SERVER=""
AFS="/afs/cern.ch/user"
EOS="/eos/user/"
PTH=""

echo "Which server do you want to mount?"
select svr in "lxplus" "EARTH" "UNMOUNT"; do
  case $svr in
    lxplus)
      connect="lxplus";
      echo ""
      echo "Username: ";
      read USER;
      echo "";
      if [ USER == "" ]
        then
          break
      fi
      if [ USER != "" ]
        then
          echo "Connecting to lxplus...";
      fi
      break;;
    earth)
      connect="earth";
      echo "";
      echo "Connecting to EARTH...";
      break;;
    UNMOUNT)
      connect="UNMOUNT";
      echo "";
      break;;
  esac
done

if [ "$connect" == "lxplus" ]
  then
    PTH="${AFS}/${USER:0:1}/${USER}/"
    SERVER="lxplus.cern.ch"
    echo "USER: ${USER}"
    echo "SERVER: ${SERVER}"
    echo "PATH: ${PTH}"
fi
if [ "$connect" == "EARTH" ]
  then
    echo "Have you checked your VPN? [y/n]"
    read vpn
    vpn=$(echo $vpn | tr '[:upper:]' '[:lower:]')

    if [ "$vpn" == "y" ]
      then
        PTH="${AFS}/${USER:0:1}/${USER}/"
        SERVER="earth.crc.nd.edu"
        echo "USER: ${USER}"
        echo "SERVER: ${SERVER}"
        echo "PATH: ${PTH}"
    fi
    if [ "$vpn" != "y" ]
      then
        echo "Start VPN first!"
    fi
fi
if [ "$connect" == "UNMOUNT" ]
  then
    echo "Unmounting ~/mnt directory..."
    diskutil unmount force ~/mnt && echo "Unmouted successfully."
  else
    echo ""
    echo "Mounting ${SERVER}..."
    echo "sshfs ${USER}@${SERVER}:${PTH} ~/mnt -o reconnect -o defer_permissions -o volname=\"${USER}@${SERVER}\""
    sshfs ${USER}@${SERVER}:${PTH} ~/mnt -o reconnect -o defer_permissions -o volname="${USER}@${SERVER}" &&
    echo "Mounted sucessfully." ||
    (echo "Trying to unmount..." &&
    diskutil unmount force ~/mnt && sshfs ${USER}@${SERVER}:${PTH} ~/mnt -o reconnect -o defer_permissions -o volname="${USER}@${SERVER}")
fi
