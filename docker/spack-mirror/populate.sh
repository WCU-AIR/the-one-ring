#!/bin/bash
# Run when container starts with mirror volume mounted: populate mirror with source tarballs only.
# Topics then fetch sources from this mirror and build locally (no pre-installed binaries).
set -e

export SPACK_ROOT=/opt/spack
. /opt/spack/share/spack/setup-env.sh

mkdir -p /opt/spack-mirror
spack mirror add local file:///opt/spack-mirror 2>/dev/null || true

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -z "$line" ] && continue
  echo "==> Mirroring sources for: $line"
  spack mirror create -d /opt/spack-mirror -D --skip-unstable-versions "$line" || true
done < /opt/spack-mirror-packages.txt
