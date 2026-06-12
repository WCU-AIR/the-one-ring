#!/bin/bash
set -e

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Base image"

source /build/base.config

#------------------------
# Install base image packages
#------------------------

apt update
apt install -y build-essential
apt install -y software-properties-common

DEBIAN_FRONTEND=noninteractive apt install -y \
    openssh-server \
    sudo \
    openssl \
    bash-completion \
    curl \
    tar \
    perl \
    zlib1g-dev \
    git \
    wget \
    vim \
    nano \
    tmux \
    wamerican \
    libc6-dev \
    libstdc++6 \
    gdb \
    valgrind \
    python3 \
    python3-pip \
    libpython3-dev \
    qemu-system-misc \
    gcc-riscv64-unknown-elf 

sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

#------------------------
# Setup user accounts
#------------------------

idnumber=1001
for uid in $USERS
do
    log_info "Bootstrapping $uid user account.."
    adduser --uid $idnumber --disabled-password --gecos "" $uid
    echo "$uid:${PASSWD_student}" | chpasswd
    echo "$uid ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$uid
    chmod 0440 /etc/sudoers.d/$uid
    idnumber=$((idnumber + 1))
done

#------------------------
# Setup gdb-peda
#------------------------
git clone https://github.com/longld/peda.git /opt/peda
for uid in $USERS
do
    echo "source /opt/peda/peda.py" > /home/${uid}/.gdbinit
    chown ${uid}:${uid} /home/${uid}/.gdbinit
done

#------------------------
# Final cleanup and setup
#------------------------
apt clean
rm -rf /var/lib/apt/lists/*

cp /build/entrypoint.sh /usr/local/bin/entrypoint.sh
chmod 755 /usr/local/bin/entrypoint.sh

cp -R /build/home/ /opt/
mkdir -p /run/sshd

