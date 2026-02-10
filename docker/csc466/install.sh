#!/bin/bash
set -e

apt update

DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential \
    curl \
    openssh-server \
    sudo \
    python3 \
    python3-pip \
    python3-venv

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

# OpenMPI
cd /build
tar xzf openmpi-5.0.6.tar.gz
cd openmpi-5.0.6
./configure --prefix=/opt/openmpi/5.0.6
make all
make install
cd /

echo "export OPENMPI_ROOT=/opt/openmpi/5.0.6" >> /etc/profile
echo "export PATH=\$PATH:/opt/openmpi/5.0.6/bin" >> /etc/profile
echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/openmpi/5.0.6/include" >> /etc/profile

# Python venv and mpi4py (no longer from base)
python3 -m venv /opt/venv/python3
. /opt/venv/python3/bin/activate
pip install numpy matplotlib
export OPENMPI_ROOT=/opt/openmpi/5.0.6
export PATH=$PATH:/opt/openmpi/5.0.6/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:${OPENMPI_ROOT}/include:${OPENMPI_ROOT}/lib
pip install mpi4py

apt clean
rm -rf /var/lib/apt/lists/*
