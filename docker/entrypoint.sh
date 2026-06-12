#!/bin/bash

echo "---> Starting sshd on the node ..."
/usr/sbin/sshd -e

if [ -z "$( ls -A '/home/student/.ssh' )" ]; then
  echo "Initializing /home/student on first run"
  cp -R /opt/home/student /home/ 
  chmod 700 /home/student/.ssh
  chmod 600 /home/student/.ssh/id_rsa
  chmod 600 /home/student/.ssh/id_rsa.pub
  chmod 600 /home/student/.ssh/authorized_keys
  chmod 600 /home/student/.ssh/config
fi

sleep infinity
