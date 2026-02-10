#!/bin/bash
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

if [ -d /opt/spack-mirror ] && [ -n "$(ls -A /opt/spack-mirror 2>/dev/null)" ]; then
  spack mirror add local file:///opt/spack-mirror 2>/dev/null || true
fi

spack install openmpi python py-numpy py-matplotlib
spack install py-mpi4py ^openmpi

cat > /etc/profile.d/spack-parallel-computing.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load openmpi
spack load python
spack load py-numpy
spack load py-matplotlib
spack load py-mpi4py
SPACK_LOAD
