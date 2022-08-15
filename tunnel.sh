#!/bin/sh

case $1 in
  connect)
      sshuttle --dns -vr castells@lxtunnel.cern.ch 137.138.0.0/16 128.141.0.0/16 128.142.0.0/16 188.184.0.0/15 --daemon --pidfile /tmp/sshuttle.pid --python=python
      shift
  ;;
  disconnect)
      kill `cat /tmp/sshuttle.pid`
      shift
  ;;
  status)
      echo "IP address as seen by CERN servers:   " `wget -O - -q "https://security.web.cern.ch/ip.php"`
      echo "IP address as seen by external sites: " `wget -O - -q "https://api.my-ip.io/ip"`
      shift
  ;;    
  *)
      # unknown option
 ;;
esac
