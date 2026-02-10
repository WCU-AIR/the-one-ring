#!/bin/bash
# Bootstrap Spack and install all packages from list (into the image). No push here.
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}}"
  line="${line%"${line##*[![:space:]]}}"
  [ -z "$line" ] && continue
  spack install "$line"
done < /build/packages.txt
