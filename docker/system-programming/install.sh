#!/bin/bash
set -e

# Spack packages (gdb, valgrind, py-six) from spack-stack base. GDB plugin not in Spack.
git clone https://github.com/longld/peda.git /opt/peda
echo "source /opt/peda/peda.py" > /home/student/.gdbinit
chown student:student /home/student/.gdbinit

cat > /etc/profile.d/spack-system-programming.sh << 'SPACK_LOAD'
. /opt/spack/share/spack/setup-env.sh
spack load gdb
spack load valgrind
spack load py-six
SPACK_LOAD
