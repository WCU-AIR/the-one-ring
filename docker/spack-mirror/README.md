# Spack mirror service

Separate **local Spack repository** service: it predownloads/prebuilds the curated Spack packages and writes them to a volume as a buildcache. Other builds or services can use that volume as a Spack mirror.

## Usage

1. Build the stack and mirror image:
   ```bash
   docker compose -f docker-compose.amd64.yml build spack-stack spack-mirror
   ```

2. Populate the mirror (run once, or when you add/change packages in `spack-stack/spack-packages.txt`):
   ```bash
   docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror
   ```
   This uses the `spack-stack` image’s already-installed packages and runs `spack buildcache push` into the `spack-mirror` volume.

3. The `spack-mirror` volume is filled with the buildcache. To use it in another build or container, mount the volume and point Spack at it, e.g.:
   ```bash
   spack mirror add local file:///opt/spack-mirror
   spack buildcache list local
   spack install --use-cache <spec>
   ```

The service is under the `tools` profile so it is not started with `docker compose up -d`; run it explicitly with `docker compose -f docker-compose.amd64.yml --profile tools run --rm spack-mirror` when you want to refresh the mirror.
