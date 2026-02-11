#!/bin/bash
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

spack install python py-numpy py-pandas py-scikit-learn

cat > /etc/profile.d/spack-machine-learning.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load python
spack load py-numpy
spack load py-pandas
spack load py-scikit-learn
SPACK_LOAD

# Clean Spack stage and caches so they are not kept in the image.
spack clean -s -c
