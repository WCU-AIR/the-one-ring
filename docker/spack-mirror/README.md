# Spack mirror service (source mirror only)

**FROM base.** The image only bootstraps Spack (no package installs). When the container runs with the mirror volume mounted, the entrypoint runs `spack mirror create` to download **source tarballs** for the specs in `packages.txt` into the mirror. No buildcache or pre-installed packages—the mirror is raw source storage only.

Topic images then mount this mirror at build time; when they run `spack install`, Spack fetches sources from the mirror and builds locally. Each topic image only contains what that topic needs (no extra storage for unused packages).

## Build order

1. Build **base** and **spack-mirror** first:
   ```bash
   docker compose build base spack-mirror
   ```

2. Populate the mirror with sources (run once, or when `packages.txt` changes):
   ```bash
   docker compose --profile tools run --rm spack-mirror
   ```
   This downloads source tarballs into `docker/spack-mirror-cache/` (bind-mounted at `/opt/spack-mirror`).

3. Build topic images with the mirror mounted so `spack install` fetches sources from the mirror and builds locally:
   ```bash
   DOCKER_BUILDKIT=1 ./scripts/build-topics.sh
   ```
   Or use `docker compose build`; topic Dockerfiles use `RUN --mount=type=bind,source=spack-mirror-cache,target=/opt/spack-mirror` so the mirror is available when the context is `./docker`.

## Updating the package list

Edit `packages.txt`, rebuild the spack-mirror image, run the container again to refresh the source mirror, then rebuild topic images.
