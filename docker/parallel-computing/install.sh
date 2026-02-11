#!/bin/bash
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

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

# Clean Spack stage and caches so they are not kept in the image.
spack clean -s -c
