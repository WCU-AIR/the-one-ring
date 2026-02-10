#!/bin/bash
# Populate the Spack mirror volume with a buildcache of the curated packages.
# Run once (or periodically) to predownload/prebuild; other services can use the volume as a mirror.
set -e

. /opt/spack/share/spack/setup-env.sh

mkdir -p /opt/spack-mirror
spack mirror add local file:///opt/spack-mirror 2>/dev/null || true
spack buildcache push local
