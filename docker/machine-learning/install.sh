#!/bin/bash
set -e

# All Spack packages (python, py-numpy, py-pandas, py-scikit-learn) from spack-stack.
cat > /etc/profile.d/spack-machine-learning.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load python
spack load py-numpy
spack load py-pandas
spack load py-scikit-learn
SPACK_LOAD
