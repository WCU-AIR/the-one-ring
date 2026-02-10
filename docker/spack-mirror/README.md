# Spack mirror service

Local Spack repository service: **FROM base** (no spack-stack). The image installs Spack and the curated packages from `packages.txt`; when the container runs with the mirror volume mounted, it pushes a buildcache to that directory so topic services can read from it at build time.

## Build order

1. Build **base** and **spack-mirror** first:
   ```bash
   docker compose -f docker-compose.amd64.yml build base spack-mirror
   ```

2. Populate the mirror (run once, or when `packages.txt` changes):
   ```bash
   docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror
   ```
   This writes the buildcache into `docker/spack-mirror-cache/` (bind-mounted at `/opt/spack-mirror`).

3. Build topic images with the mirror mounted so `spack install` uses the cache:
   ```bash
   DOCKER_BUILDKIT=1 ./scripts/build-topics.sh
   ```
   Or use `docker compose build`; topic Dockerfiles use `RUN --mount=type=bind,source=spack-mirror-cache,target=/opt/spack-mirror` so the mirror is available when the context is `./docker`.

## Updating the package list

Edit `packages.txt`, rebuild the spack-mirror image, run the container again to refresh the cache, then rebuild topic images.
