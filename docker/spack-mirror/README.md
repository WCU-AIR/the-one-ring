# Spack mirror service (optional, source mirror only)

**Optional.** Topic builds **do not require** a local mirror; they fetch sources from the network by default. This service is for users who want a local source mirror (e.g. offline use or to avoid re-downloading tarballs).

**FROM base.** The image only bootstraps Spack (no package installs). When the container runs with the mirror volume mounted, the entrypoint runs `spack mirror create` to download **source tarballs** for the specs in `packages.txt` into the mirror. No buildcache or pre-installed packages—the mirror is raw source storage only.

Topic Dockerfiles **do not** mount this mirror by default. To use it, you would need to add the mirror mount and `spack mirror add` back into the topic Dockerfiles and install scripts.

## Build and populate (optional)

1. Build **base** and **spack-mirror**:
   ```bash
   docker compose build base spack-mirror
   ```

2. Populate the mirror with sources (run once, or when `packages.txt` changes):
   ```bash
   docker compose --profile tools run --rm spack-mirror
   ```
   This downloads source tarballs into `docker/spack-mirror-cache/` (bind-mounted at `/opt/spack-mirror`).

## Updating the package list

Edit `packages.txt`, rebuild the spack-mirror image, run the container again to refresh the source mirror.
