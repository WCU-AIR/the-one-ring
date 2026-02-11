#!/bin/bash
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

spack install openjdk python py-pandas py-pyarrow

cat > /etc/profile.d/spack-big-data.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load openjdk
spack load python
spack load py-pandas
spack load py-pyarrow
SPACK_LOAD

# Clean Spack stage and caches so they are not kept in the image.
spack clean -s -c
