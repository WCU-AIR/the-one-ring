#!/bin/bash
set -e

apt update
DEBIAN_FRONTEND=noninteractive apt install -y curl gfortran openssh-server sudo

source /build/base.config
idnumber=1001
for uid in $USERS; do
  adduser --uid $idnumber --disabled-password --gecos "" $uid
  echo "$uid:${PASSWD_student}" | chpasswd
  echo "$uid ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$uid
  chmod 0440 /etc/sudoers.d/$uid
  idnumber=$((idnumber + 1))
done

ssh-keygen -A
cp /build/entrypoint.sh /usr/local/bin/entrypoint.sh
chmod 755 /usr/local/bin/entrypoint.sh

apt clean
rm -rf /var/lib/apt/lists/*
