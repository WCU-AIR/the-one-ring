#!/bin/bash
set -e

# shellcheck source=/dev/null
. /build/bootstrap.sh

# Use local mirror if present (populate with: docker compose --profile tools run --rm spack-mirror)
if [ -d /opt/spack-mirror ] && [ -n "$(ls -A /opt/spack-mirror 2>/dev/null)" ]; then
  spack mirror add local file:///opt/spack-mirror 2>/dev/null || true
fi

spack install gdb valgrind py-six

# GDB plugin not in Spack
git clone https://github.com/longld/peda.git /opt/peda
echo "source /opt/peda/peda.py" > /home/student/.gdbinit
chown student:student /home/student/.gdbinit

cat > /etc/profile.d/spack-system-programming.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load gdb
spack load valgrind
spack load py-six
SPACK_LOAD
