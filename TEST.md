# Test plan: per-service image verification

After building images (see README.md), use this plan to verify each service image. Run commands from the **repository root** with the same `docker-compose.yml` you used to build.

**Prerequisites**

- Images built (at least the ones you want to test).
- For topic services that use Spack: `spack-mirror` built and mirror populated (source tarballs) so topic builds can fetch from it; tests only verify the **already-built** image.

---

## 1. Base

**Purpose:** Minimal runtime (user `student`, sudo, ssh, curl). No long-running process; compose overrides with `command: ["true"]`.

| Step | Command | Expected |
|------|---------|----------|
| Run as student | `docker compose run --rm base whoami` | `student` |
| Sudo works | `docker compose run --rm base sudo whoami` | `root` |
| SSH server present | `docker compose run --rm base which sshd` or `test -x /usr/sbin/sshd && echo ok` | path or `ok` |
| Curl present | `docker compose run --rm base curl -sSf --version | head -1` | curl version line |

---

## 2. Spack-mirror

**Purpose:** Populates the mounted mirror volume with **source tarballs only** (no buildcache). Run with volume mount; entrypoint runs `spack mirror create` for each spec in `packages.txt`.

| Step | Command | Expected |
|------|---------|----------|
| Run with mirror volume | `docker compose --profile tools run --rm spack-mirror` | Exits 0; logs show "Mirroring sources for: &lt;spec&gt;" per package |
| Mirror has content | `ls -la docker/spack-mirror-cache/` (after run) | Non-empty dir (source tarballs and mirror index, not buildcache) |

---

## 3. IDE

**Purpose:** code-server on port 8088, shared home skeleton.

| Step | Command | Expected |
|------|---------|----------|
| code-server version | `docker compose run --rm ide code-server --version` | Version string |
| User is student | `docker compose run --rm ide whoami` | `student` |
| Server responds (optional) | Start with `docker compose up -d ide`, then `curl -sS -o /dev/null -w "%{http_code}" http://127.0.0.1:18088/` | `200` or `301`/`302`; then `docker compose stop ide` |

---

## 4. System-programming

**Purpose:** GDB, Valgrind, py-six (Spack); peda (GDB plugin). SSHD + sleep.

| Step | Command | Expected |
|------|---------|----------|
| Load env and GDB | `docker compose run --rm system-programming bash -c 'source /etc/profile.d/spack-system-programming.sh && gdb --version'` | GDB version |
| Valgrind | `docker compose run --rm system-programming bash -c 'source /etc/profile.d/spack-system-programming.sh && valgrind --version'` | Valgrind version |
| Python six | `docker compose run --rm system-programming bash -c 'source /etc/profile.d/spack-system-programming.sh && python3 -c "import six; print(six.__version__)"'` | Version string |
| PEDA present | `docker compose run --rm system-programming test -f /opt/peda/peda.py && echo ok` | `ok` |

---

## 5. Parallel-computing

**Purpose:** OpenMPI, Python, py-numpy, py-matplotlib, py-mpi4py (Spack).

| Step | Command | Expected |
|------|---------|----------|
| MPI compiler | `docker compose run --rm parallel-computing bash -c 'source /etc/profile.d/spack-parallel-computing.sh && mpicc --version'` | Compiler version |
| MPI run | `docker compose run --rm parallel-computing bash -c 'source /etc/profile.d/spack-parallel-computing.sh && mpirun --version'` | Open MPI version |
| Python + mpi4py | `docker compose run --rm parallel-computing bash -c 'source /etc/profile.d/spack-parallel-computing.sh && python3 -c "import mpi4py; print(mpi4py.__version__)"'` | Version string |
| NumPy/Matplotlib | `docker compose run --rm parallel-computing bash -c 'source /etc/profile.d/spack-parallel-computing.sh && python3 -c "import numpy, matplotlib; print(numpy.__version__, matplotlib.__version__)"'` | Two version strings |

---

## 6. Big-data

**Purpose:** OpenJDK, Python, py-pandas, py-pyarrow (Spack).

| Step | Command | Expected |
|------|---------|----------|
| Java | `docker compose run --rm big-data bash -c 'source /etc/profile.d/spack-big-data.sh && java -version'` | OpenJDK version |
| Python pandas | `docker compose run --rm big-data bash -c 'source /etc/profile.d/spack-big-data.sh && python3 -c "import pandas; print(pandas.__version__)"'` | Version string |
| PyArrow | `docker compose run --rm big-data bash -c 'source /etc/profile.d/spack-big-data.sh && python3 -c "import pyarrow; print(pyarrow.__version__)"'` | Version string |

---

## 7. Machine-learning

**Purpose:** Python, py-numpy, py-pandas, py-scikit-learn (Spack).

| Step | Command | Expected |
|------|---------|----------|
| NumPy | `docker compose run --rm machine-learning bash -c 'source /etc/profile.d/spack-machine-learning.sh && python3 -c "import numpy; print(numpy.__version__)"'` | Version string |
| Pandas | `docker compose run --rm machine-learning bash -c 'source /etc/profile.d/spack-machine-learning.sh && python3 -c "import pandas; print(pandas.__version__)"'` | Version string |
| Scikit-learn | `docker compose run --rm machine-learning bash -c 'source /etc/profile.d/spack-machine-learning.sh && python3 -c "import sklearn; print(sklearn.__version__)"'` | Version string |

---

## 8. Embedded-system

**Purpose:** QEMU, OpenOCD (Spack); gcc-riscv64-unknown-elf, gcc-arm-none-eabi (apt).

| Step | Command | Expected |
|------|---------|----------|
| QEMU | `docker compose run --rm embedded-system bash -c 'source /etc/profile.d/spack-embedded-system.sh && qemu-system-x86_64 --version'` | QEMU version (or arm/riscv variant) |
| OpenOCD | `docker compose run --rm embedded-system bash -c 'source /etc/profile.d/spack-embedded-system.sh && openocd --version'` | OpenOCD version |
| RISC-V toolchain | `docker compose run --rm embedded-system riscv64-unknown-elf-gcc --version` | GCC version |
| ARM toolchain | `docker compose run --rm embedded-system arm-none-eabi-gcc --version` | GCC version |

---

## Standalone / alternate images (optional)

If you build **standalone** course images (not from the main compose), you can use the same idea: run the image and assert key tools and user.

### CSC331 (standalone)

Built from `docker/csc331` (e.g. `docker build -f docker/csc331/Dockerfile -t test-csc331 docker/`).

| Step | Command | Expected |
|------|---------|----------|
| User | `docker run --rm test-csc331 whoami` | `student` |
| GDB | `docker run --rm test-csc331 gdb --version` | GDB version |
| Valgrind | `docker run --rm test-csc331 valgrind --version` | Valgrind version |
| QEMU | `docker run --rm test-csc331 qemu-system-x86_64 --version` | QEMU version |
| RISC-V GCC | `docker run --rm test-csc331 riscv64-unknown-elf-gcc --version` | GCC version |

### CSC466 (standalone)

Built from `docker/csc466` (e.g. `docker build -f docker/csc466/Dockerfile -t test-csc466 docker/`).

| Step | Command | Expected |
|------|---------|----------|
| User | `docker run --rm test-csc466 whoami` | `student` |
| OpenMPI | `docker run --rm test-csc466 bash -c 'source /etc/profile && mpirun --version'` | Open MPI version |
| mpi4py | `docker run --rm test-csc466 bash -c 'source /etc/profile && /opt/venv/python3/bin/python -c "import mpi4py; print(mpi4py.__version__)"'` | Version string |

---

## Quick one-liner (main compose services)

From repo root, after building all main images:

```bash
# Base
docker compose run --rm base whoami
docker compose run --rm base sudo whoami

# IDE
docker compose run --rm ide code-server --version

# Topic services (Spack-loaded tools)
docker compose run --rm system-programming bash -c 'source /etc/profile.d/spack-system-programming.sh && gdb --version && valgrind --version'
docker compose run --rm parallel-computing bash -c 'source /etc/profile.d/spack-parallel-computing.sh && mpirun --version && python3 -c "import mpi4py"'
docker compose run --rm big-data bash -c 'source /etc/profile.d/spack-big-data.sh && java -version && python3 -c "import pandas, pyarrow"'
docker compose run --rm machine-learning bash -c 'source /etc/profile.d/spack-machine-learning.sh && python3 -c "import numpy, pandas, sklearn"'
docker compose run --rm embedded-system bash -c 'source /etc/profile.d/spack-embedded-system.sh && qemu-system-x86_64 --version' && docker compose run --rm embedded-system riscv64-unknown-elf-gcc --version
```

All commands should exit 0. Spack-mirror is tested by running it once (with profile tools) and checking `docker/spack-mirror-cache/` is populated with source tarballs (not buildcache).
