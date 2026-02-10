#!/bin/bash
# Run when container starts with mirror volume mounted: push image's Spack installs to volume.
set -e

. /opt/spack/share/spack/setup-env.sh

mkdir -p /opt/spack-mirror
spack mirror add local file:///opt/spack-mirror 2>/dev/null || true
spack buildcache push local
