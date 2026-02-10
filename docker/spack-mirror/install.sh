#!/bin/bash
# Bootstrap Spack only. No package installs; the mirror holds source tarballs only.
# populate.sh (at container run) uses "spack mirror create" to fill the mirror with sources.
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

# Keep package list for runtime so populate.sh can run "spack mirror create" for each spec.
cp /build/packages.txt /opt/spack-mirror-packages.txt
