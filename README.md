# The One Ring framework

- This is the aggregarion of all other research and education containerized environments. Using multiple Docker compose files, this framework aims to provide users with a dynamic setup that can be quickly extended based on their own teach/learning/researching progress.

---

## Overview of the refactored setup (docker-compose.amd64.yml)

The main compose file (`docker-compose.amd64.yml`) organizes services by **topic** instead of by class, shares state via **three volumes**, and uses **Spack** for software so the stack can be reused and cached like an HPC center.

### Image layers

1. **base** – Minimal common runtime: Ubuntu, `sudo`, `openssh-server`, `curl`, and a shared user (`student`, uid 1001). No IDE or course-specific tools.
2. **spack-stack** – Builds on `base`; installs **Spack** and a curated set of packages (gdb, valgrind, OpenMPI, Python, numpy, pandas, qemu, openocd, etc.) from `docker/spack-stack/spack-packages.txt`. Topic services use this image as their base so they get Spack and all packages without rebuilding.
3. **ide** – Builds on `base` only; runs **code-server** (VS Code in the browser). No Spack; shares the same volumes as topic services.
4. **Topic services** – Each builds on `spack-stack` and only adds topic-specific bits and a `/etc/profile.d` script that runs `spack load` for that topic’s subset:
   - **system-programming** – gdb, valgrind, py-six, peda (GDB plugin).
   - **parallel-computing** – OpenMPI, python, py-numpy, py-matplotlib, py-mpi4py.
   - **big-data** – openjdk, python, py-pandas, py-pyarrow.
   - **machine-learning** – python, py-numpy, py-pandas, py-scikit-learn.
   - **embedded-system** – qemu, openocd; cross-compilers (riscv, arm) from apt.
5. **spack-mirror** – A **separate local Spack repository** service. It uses the `spack-stack` image and runs `spack buildcache push` into a volume (`spack-mirror`). You run it once (or when the package list changes) to predownload/prebuild the stack; other builds or containers can use that volume as a Spack mirror. It is under the `tools` profile and is not started with `up -d`.

### Shared volumes

- **home** (Docker volume) – Shared home directory; same user (uid 1001) across services.
- **software** (Docker volume) – Shared software/install space.
- **data** (host mount) – Default `./data` on the host, override with `DATA_PATH=/path/on/host`. All services mount the same path.

### Commands

~~~bash
# Build everything (base → spack-stack → topic images; spack-stack build can be slow the first time)
docker compose -f docker-compose.amd64.yml build

# Populate the local Spack mirror (run when you add/change packages in spack-stack/spack-packages.txt)
docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror

# Start IDE and topic services
docker compose -f docker-compose.amd64.yml up -d ide system-programming parallel-computing

# Override the host path for /data
DATA_PATH=/mnt/shared/data docker compose -f docker-compose.amd64.yml up -d
~~~

### Updating the Spack stack

- Edit `docker/spack-stack/spack-packages.txt` (one spec per line).
- Rebuild: `docker compose -f docker-compose.amd64.yml build spack-stack`, then rebuild any topic images that use it.
- Optionally refresh the mirror: `docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror`.

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
