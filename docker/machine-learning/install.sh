#!/bin/bash
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

if [ -d /opt/spack-mirror ] && [ -n "$(ls -A /opt/spack-mirror 2>/dev/null)" ]; then
  spack mirror add local file:///opt/spack-mirror 2>/dev/null || true
fi

spack install python py-numpy py-pandas py-scikit-learn

cat > /etc/profile.d/spack-machine-learning.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load python
spack load py-numpy
spack load py-pandas
spack load py-scikit-learn
SPACK_LOAD
