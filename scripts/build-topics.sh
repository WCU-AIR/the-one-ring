#!/bin/bash
# Build topic images with the Spack mirror mounted so spack install uses the buildcache.
# Run from repo root. Requires: base and spack-mirror built, mirror populated.
set -e

cd "$(dirname "$0")/.."
MIRROR="${MIRROR:-docker/spack-mirror-cache}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.amd64.yml}"

for topic in system-programming parallel-computing big-data machine-learning embedded-system; do
  echo "Building $topic with mirror mount $MIRROR ..."
  DOCKER_BUILDKIT=1 docker build \
    -f "docker/${topic}/Dockerfile" \
    --mount=type=bind,source="$(pwd)/${MIRROR}",target=/opt/spack-mirror \
    -t "linhbngo/onering-amd64:${topic}" \
    docker/
done

echo "Done. Start with: docker compose -f $COMPOSE_FILE up -d ide system-programming ..."
