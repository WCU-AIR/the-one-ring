#!/bin/bash
set -e

# All Spack packages (openmpi, python, py-numpy, py-matplotlib, py-mpi4py) from spack-stack.
cat > /etc/profile.d/spack-parallel-computing.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load openmpi
spack load python
spack load py-numpy
spack load py-matplotlib
spack load py-mpi4py
SPACK_LOAD
