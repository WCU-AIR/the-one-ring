#!/bin/bash
# Minimal bootstrap for Spack: apt (build-essential, git, python3), clone Spack, register compiler.
# Source this from topic install scripts, then run topic-specific "spack install ...".
set -e

apt update
DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential \
    ca-certificates \
    git \
    python3

if [ ! -d /opt/spack ]; then
  git clone --depth 1 https://github.com/spack/spack.git /opt/spack
fi

# Required when building under Rosetta (amd64 emulation on Mac); harmless otherwise.
export SPACK_ROOT=/opt/spack
# shellcheck source=/dev/null
. /opt/spack/share/spack/setup-env.sh
spack compiler find

# Avoid clingo "Only external, or concrete, compilers are allowed for the fortran language".
# Original concretizer works in containers/emulation (e.g. Rosetta) without that restriction.
mkdir -p /root/.spack
printf 'config:\n  concretizer: original\n' > /root/.spack/config.yaml

# When /software is mounted (topic builds), use it as the Spack install tree so all topic builds share one store.
# Subsequent topic builds then reuse packages already installed by earlier builds; at runtime the same mount provides them.
# Write site-scope config directly (avoids spack config add CLI differences across Spack versions).
if [ -d /software ]; then
  mkdir -p /opt/spack/etc/spack/site
  printf 'config:\n  install_tree:\n    root: /software\n' > /opt/spack/etc/spack/site/config.yaml
fi

apt clean
rm -rf /var/lib/apt/lists/*
