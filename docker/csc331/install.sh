#!/bin/bash
set -e

apt update

# Dev and runtime (no code-server)
DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential \
    curl \
    git \
    gdb \
    valgrind \
    qemu-system-misc \
    gcc-riscv64-unknown-elf \
    python3-six \
    openssh-server \
    sudo

apt clean
rm -rf /var/lib/apt/lists/*

# Same user as IDE and other services for shared home volume
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

# GDB peda (optional)
git clone https://github.com/longld/peda.git /opt/peda
echo "source /opt/peda/peda.py" > /home/student/.gdbinit
chown student:student /home/student/.gdbinit
