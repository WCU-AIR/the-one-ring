#!/bin/bash
set -e

# QEMU and OpenOCD from spack-stack. Cross-compilers from apt (not in Spack in practice).
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gcc-riscv64-unknown-elf \
    gcc-arm-none-eabi
apt-get clean
rm -rf /var/lib/apt/lists/*

cat > /etc/profile.d/spack-embedded-system.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load qemu
spack load openocd
SPACK_LOAD
