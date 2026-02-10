#!/bin/bash
set -e

# All Spack packages (openjdk, python, py-pandas, py-pyarrow) from spack-stack.
cat > /etc/profile.d/spack-big-data.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load openjdk
spack load python
spack load py-pandas
spack load py-pyarrow
SPACK_LOAD
