#!/bin/bash
# Preload Spack and a curated set of packages. Topic images use this as base.
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}}"
  line="${line%"${line##*[![:space:]]}}"
  [ -z "$line" ] && continue
  spack install "$line"
done < /build/spack-packages.txt
