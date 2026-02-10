# The One Ring framework

- This is the aggregation of all other research and education containerized environments. Using multiple Docker compose files, this framework aims to provide users with a dynamic setup that can be quickly extended based on their own teach/learning/researching progress.

- In this latest update, I rethink how I approach the `ring`. Rather than group them by courses, I have decided 
to group them by topics, enabling container reuse for related courses (e.g., Computer Systems and Operating Systems). 
I also adapt the approach used by supercomputing center by moving all software packages into a shared mounted 
volume. This allows for easier update/modification. 

---

## Overview

The main compose file organizes services by **topic**, shares state via **three volumes**, and uses **Spack** with a **local source mirror**: base and spack-mirror are built first; topic services use the base layer and a normal Spack workflow, fetching sources from the mirror at build time and building locally.

### Build order

1. **base** – Built first. Minimal runtime: Ubuntu, `sudo`, `openssh-server`, `curl`, `gfortran`, shared user (`student`, uid 1001).
2. **spack-mirror** – Built second (depends on base). Image: FROM base; bootstraps Spack only (no package installs). When the container runs with the mirror volume mounted, it runs `spack mirror create` to download **source tarballs** for the specs in `docker/spack-mirror/packages.txt` into `docker/spack-mirror-cache/`. Mirror is source storage only—no buildcache or pre-installed packages. Run once to populate the mirror so topic builds can fetch sources from it.
3. **Topic services** – Each FROM base; normal Spack workflow (bootstrap + `spack install`). At build time they mount the mirror and fetch sources from it, then build locally. Each topic installs only its packages and adds a `/etc/profile.d` script for `spack load`:
   - **system-programming** – gdb, valgrind, py-six, peda (GDB plugin).
   - **parallel-computing** – openmpi, python, py-numpy, py-matplotlib, py-mpi4py.
   - **big-data** – openjdk, python, py-pandas, py-pyarrow.
   - **machine-learning** – python, py-numpy, py-pandas, py-scikit-learn.
   - **embedded-system** – qemu (Spack); openocd, cross-compilers (riscv, arm) from apt.
4. **ide** – FROM base only; runs **code-server**. No Spack.

### Platform

- **All images are linux/amd64 only.** On Apple Silicon / ARM hosts, use the same `docker-compose.yml`; Docker will run amd64 images via emulation. ARM-native builds are no longer supported (see `docker-compose.arm.yml`).

### Shared volumes

- **home**, **software** (Docker volumes) – Shared across services.
- **data** (host mount) – Default `./data`; override with `DATA_PATH=/path/on/host`.
- **Spack mirror** – Bind mount `./docker/spack-mirror-cache`; populated by the spack-mirror service with source tarballs only; mounted during topic builds so they fetch sources from the mirror and build locally.

---

## Build Process

### Build Logs

To debug the build process, you can redirect the build log to a build file inside the 
`logs` directory. It is recommended that you build and test the infrastructure one service at 
a time. 

- Example build service `base` with logging for **Mac/Linux**

~~~
docker compose --progress=plain --ansi=never build base 2>&1 | tee logs/build-base.log
~~~

- Example build service `base` with logging for **Windows**

~~~
docker compose --progress=plain --ansi=never build 2>&1 | Tee-Object -FilePath .\logs\build-base.log
~~~

### Service: base

Run the following command to build `base`:

~~~
docker compose --progress=plain --ansi=never build base 2>&1 | tee logs/build-base.log
~~~

Run the following command to test the build:

~~~
docker compose run --rm base whoami            
~~~

The final expected outcome is:

~~~
student
~~~

### Service: spack-mirror

We first build `spack-mirror`. This service will attempt to create a local 
spack repository to be used for future installation for other services. 
The custom package list can be modified via `packages.txt`. 

~~~bash
docker compose build spack-mirror 2>&1 | tee logs/build-spack-mirror.log
~~~

Once everything is build, the test is also the initial first run, where 
the tar packages are downloaded and cache. These will help with future 
service runs/builds. 

~~~bash
docker compose --profile tools run --rm spack-mirror
~~~

After this run, the content of `spack-mirror-cache` will be populated. 
This content is not included in the repository. 

### Services: topical services

The rest of the services can be build all at once or individually. To build 
everything at once, run the following: 

~~~
DOCKER_BUILDKIT=1 ./scripts/build-topics.sh
~~~

# Or build via compose (topic builds will use mirror if docker/spack-mirror-cache exists and is populated)
docker compose build

# Start IDE and topic services
docker compose up -d ide system-programming parallel-computing

# Override /data host path
DATA_PATH=/mnt/shared/data docker compose up -d
~~~

### Updating the Spack stack

- Edit `docker/spack-mirror/packages.txt` (one spec per line).
- Rebuild spack-mirror: `docker compose build spack-mirror`.
- Run spack-mirror again to refresh the cache: `docker compose --profile tools run --rm spack-mirror`.
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
