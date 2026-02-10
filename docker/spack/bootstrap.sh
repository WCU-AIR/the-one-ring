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

# shellcheck source=/dev/null
. /opt/spack/share/spack/setup-env.sh
spack compiler find

apt clean
rm -rf /var/lib/apt/lists/*
