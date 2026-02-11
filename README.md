# The One Ring framework

- This is the aggregation of all other research and education containerized environments. Using multiple Docker compose files, this framework aims to provide users with a dynamic setup that can be quickly extended based on their own teach/learning/researching progress.

- In this latest update, I rethink how I approach the `ring`. Rather than group them by courses, I have decided 
to group them by topics, enabling container reuse for related courses (e.g., Computer Systems and Operating Systems). 
I also adapt the approach used by supercomputing center by moving all software packages into a shared mounted 
volume. This allows for easier update/modification. 

---

## Overview

The main compose file organizes services by **topic** and shares state via **home** and a shared **Spack install store** at `/software`. Topic services use the base layer and Spack; they **fetch sources from the network** at build time (no local mirror required) and install into the shared store so subsequent topic builds reuse dependencies. **Caches are cleaned** after each build (apt, Spack stage and cache) to avoid extra storage.

### Cloning repository

- If you clone into a Windows environment, makes sure that your git is set to keep `LF`:

~~~
git config --global core.autocrlf false
git clone https://github.com/ngo-classes/the-one-ring
cd the-one-ring
~~~

### Build order

1. **base** – Built first. Minimal runtime: Ubuntu, `sudo`, `openssh-server`, `curl`, `gfortran`, shared user (`student`, uid 1001).
2. **Topic services** – Each FROM base; Spack fetches **sources from the network** (no mirror required). At build time they mount a **shared Spack install store** at `/software` (`docker/spack-store`); the first topic you build populates it and **subsequent topic builds reuse** already-installed dependencies. Build topics one at a time; later builds are faster. After each topic build, **Spack stage and caches are cleaned** (`spack clean -s -c`) so they are not kept in the image. At runtime, `/software` is the same bind mount so containers see the shared installs. Each topic adds a `/etc/profile.d` script for `spack load`.
   - **system-programming** – gdb, valgrind, py-six, peda (GDB plugin).
   - **parallel-computing** – openmpi, python, py-numpy, py-matplotlib, py-mpi4py.
   - **big-data** – openjdk, python, py-pandas, py-pyarrow.
   - **machine-learning** – python, py-numpy, py-pandas, py-scikit-learn.
   - **embedded-system** – qemu (Spack); openocd, cross-compilers (riscv, arm) from apt.
3. **ide** – FROM base only; runs **code-server**. No Spack.

**Optional: spack-mirror** (profile `tools`) – If you want a local source mirror to avoid re-downloading tarballs or for offline use, build and run the spack-mirror service; topic builds do **not** require it by default.

### Platform

- **All images are linux/amd64 only.** On Apple Silicon / ARM hosts, use the same `docker-compose.yml`; Docker will run amd64 images via emulation. ARM-native builds are no longer supported (see `docker-compose.arm.yml`).

### Shared volumes

- **home** (Docker volume) – Shared across services.
- **software** – Bind mount `./docker/spack-store` at `/software`; shared **Spack install tree**. Topic builds write here; subsequent builds and all running containers see the same installs. Not in the repo (see `.gitignore`).
- **data** (host mount) – Default `./data`; override with `DATA_PATH=/path/on/host`.

**Cache cleanup:** Each topic build runs `apt clean`, `rm -rf /var/lib/apt/lists/*` (in bootstrap) and `spack clean -s -c` (stage and cache) at the end so build caches are not kept in the image or on disk.

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
docker compose --progress=plain --ansi=never build base 2>&1 | Tee-Object -FilePath .\logs\build-base.log
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

### Service: spack-mirror (optional)

Topic builds **do not require** a local mirror; they fetch sources from the network. If you want a local source mirror (e.g. for offline use or to avoid re-downloading tarballs), use the spack-mirror service (profile `tools`):

~~~bash
docker compose build base spack-mirror
docker compose --profile tools run --rm spack-mirror
~~~

This populates `docker/spack-mirror-cache/` with source tarballs. Topic Dockerfiles no longer mount the mirror by default; you can add it back in the Dockerfile and install script if you want topic builds to use it.

### Services: topical services

Topic images (system-programming, parallel-computing, big-data, machine-learning, embedded-system) can be built **one by name** or all at once using **docker compose**. No mirror required; Spack fetches sources from the network. Requires **base** and the shared store directory `docker/spack-store` (created automatically or add a `.gitkeep`).

**Shared Spack store at `/software`:** Topic builds mount `docker/spack-store` at `/software` and Spack is configured to use it as the install tree. The **first** topic you build installs its packages (and dependencies) into that store. **Later** topic builds see those installs and reuse them instead of rebuilding, so subsequent builds are much faster. At runtime, the same directory is mounted at `/software` so all containers see the shared installs.

**Build a single topic** (recommended: build one at a time)

~~~bash
docker compose --progress=plain --ansi=never build system-programming 2>&1 | tee logs/build-system-programming.log
~~~

Then build others; they will reuse packages already in `docker/spack-store`:

~~~bash
docker compose build parallel-computing
docker compose build big-data
# ...
~~~

**Build all topic services** (long run; later images still reuse the store)

~~~bash
docker compose build
~~~

Valid service names: `system-programming`, `parallel-computing`, `big-data`, `machine-learning`, `embedded-system`.

**Start services:** e.g. `docker compose up -d ide system-programming parallel-computing`. Override data path: `DATA_PATH=/mnt/shared/data docker compose up -d`.

### Updating the Spack stack

- To add or change packages, edit the topic’s `install.sh` (e.g. `docker/system-programming/install.sh`) and rebuild that topic: `docker compose build system-programming`.
- Rebuild topic images as needed: `docker compose build [SERVICE]` or `docker compose build`.
- (Optional) If you use spack-mirror: edit `docker/spack-mirror/packages.txt`, rebuild spack-mirror, run `docker compose --profile tools run --rm spack-mirror`, then rebuild topics.

