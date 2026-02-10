# The One Ring framework

- This is the aggregarion of all other research and education containerized environments. Using multiple Docker compose files, this framework aims to provide users with a dynamic setup that can be quickly extended based on their own teach/learning/researching progress.

---

## Overview of the refactored setup (docker-compose.amd64.yml)

The main compose file organizes services by **topic**, shares state via **three volumes**, and uses **Spack** with a **local mirror**: base and spack-mirror are built first; topic services use the base layer and a normal Spack workflow, reading from the spack-mirror at build time.

### Build order

1. **base** – Built first. Minimal runtime: Ubuntu, `sudo`, `openssh-server`, `curl`, shared user (`student`, uid 1001).
2. **spack-mirror** – Built second (depends on base). Image: FROM base; installs Spack and a curated set of packages from `docker/spack-mirror/packages.txt`, then when the container runs (with the mirror volume mounted), pushes a buildcache to `docker/spack-mirror-cache/`. Run once to populate the mirror so topic builds can use it.
3. **Topic services** – Each FROM base; normal Spack workflow (bootstrap + `spack install`). At build time they read from the spack-mirror when the mirror directory is mounted, so installs use the buildcache. Each topic adds only its packages and a `/etc/profile.d` script for `spack load`:
   - **system-programming** – gdb, valgrind, py-six, peda (GDB plugin).
   - **parallel-computing** – openmpi, python, py-numpy, py-matplotlib, py-mpi4py.
   - **big-data** – openjdk, python, py-pandas, py-pyarrow.
   - **machine-learning** – python, py-numpy, py-pandas, py-scikit-learn.
   - **embedded-system** – qemu, openocd; cross-compilers (riscv, arm) from apt.
4. **ide** – FROM base only; runs **code-server**. No Spack.

### Shared volumes

- **home**, **software** (Docker volumes) – Shared across services.
- **data** (host mount) – Default `./data`; override with `DATA_PATH=/path/on/host`.
- **Spack mirror** – Bind mount `./docker/spack-mirror-cache`; populated by the spack-mirror service and mounted during topic builds so they read from the mirror.

### Commands

~~~bash
# 1) Build base and spack-mirror first
docker compose -f docker-compose.amd64.yml build base spack-mirror

# 2) Populate the mirror (run once, or when docker/spack-mirror/packages.txt changes)
docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror

# 3) Build topic images with mirror mounted (so spack install uses the buildcache)
DOCKER_BUILDKIT=1 ./scripts/build-topics.sh

# Or build via compose (topic builds will use mirror if docker/spack-mirror-cache exists and is populated)
docker compose -f docker-compose.amd64.yml build

# Start IDE and topic services
docker compose -f docker-compose.amd64.yml up -d ide system-programming parallel-computing

# Override /data host path
DATA_PATH=/mnt/shared/data docker compose -f docker-compose.amd64.yml up -d
~~~

### Updating the Spack stack

- Edit `docker/spack-mirror/packages.txt` (one spec per line).
- Rebuild spack-mirror: `docker compose -f docker-compose.amd64.yml build spack-mirror`.
- Run spack-mirror again to refresh the cache: `docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror`.
- Rebuild topic images (with `./scripts/build-topics.sh` or `docker compose build`).

---

## Class-specific setups (legacy / alternate compose files)

- If you clone into a Windows environment, makes sure that your git is set to keep `LF`:

~~~
git config --global core.autocrlf false
git clone https://github.com/ngo-classes/the-one-ring
cd the-one-ring
~~~

### CSC331: Operating System

~~~
docker compose -f docker-compose.yml up 331-head
~~~

### CSC467: Big Data Engineering

- If you are an instructor with lecture nodes and grading, build `467-instructor`:

~~~
docker compose -f docker-compose.csc467.yml build 467-instructor --no-cache
docker compose -f docker-compose.csc467.yml up 467-instructor -d
~~~

- Otherwise, build `467-student`:

~~~
docker compose -f docker-compose.csc467.yml build 467-student --no-cache
docker compose -f docker-compose.csc467.yml up 467-student -d
~~~

- Launch the worker nodes:

~~~
docker compose -f docker-compose.csc467.yml up 467-worker -d --scale 467-worker=4
~~~


### CSC46: Distributed and Parallel Computing

- Prior to launching, check `docker-compose.yml` to adjust the `resources` sections of the services being launched. 
    - It is possible to launch more than two compute nodes (or launch with just one node) by creating additional copy of the `compute-01` service section. You can create the new `compute-xx` service sections and make sure that the `hostname` and `container_name` sections for the new services are changed accordingly. 
- If you are an instructor with lecture nodes and grading, build and launch `466-instructor`:

~~~
docker compose -f docker-compose.csc466.yml build 466-instructor --no-cache
docker compose -f docker-compose.csc466.yml up 466-instructor -d
~~~

- Otherwise, build and launch `466-student`:

~~~
docker compose -f docker-compose.csc466.yml build 466-student --no-cache
docker compose -f docker-compose.csc466.yml up 466-student -d
~~~

- Launch the compute nodes
~~~
docker compose -f docker-compose.csc466.yml up compute01 -d
docker compose -f docker-compose.csc466.yml up compute02 -d
~~~

### Test

- Access the VSCode server via http://127.0.0.1:18088/
    - Password is **goldenrams** 
- Open a terminal
- Test the environment as follows:

~~~
mpicc -o hello mpi_hello_world.c 
mpirun --host compute01:2,compute02:2 -np 4 ./hello
~~~


After this is done, update `.gitignore` so that temporary files generated in home are not included. 

### Build mkdocs server (for instructor)

`mkdocs serve --dirty --dev-addr=0.0.0.0:8000` to support external view of mkdocs
