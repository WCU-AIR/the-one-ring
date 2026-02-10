#!/bin/bash
# Build topic images with the Spack mirror mounted so spack install fetches sources from it.
# Run from repo root. Requires: base and spack-mirror built, mirror populated.
# Usage: ./scripts/build-topics.sh [SERVICE]
#   If SERVICE is given, build only that topic (e.g. system-programming).
#   If no argument, build all topic services.
set -e

ALL_TOPICS="system-programming parallel-computing big-data machine-learning embedded-system"

cd "$(dirname "$0")/.."
MIRROR="${MIRROR:-docker/spack-mirror-cache}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

if [ $# -ge 1 ]; then
  topic="$1"
  case " $ALL_TOPICS " in
    *" $topic "*) ;;
    *) echo "Unknown topic: $topic. Valid: $ALL_TOPICS" >&2; exit 1 ;;
  esac
  topics="$topic"
else
  topics="$ALL_TOPICS"
fi

for topic in $topics; do
  echo "Building $topic with mirror mount $MIRROR ..."
  DOCKER_BUILDKIT=1 docker build \
    -f "docker/${topic}/Dockerfile" \
    --mount=type=bind,source="$(pwd)/${MIRROR}",target=/opt/spack-mirror \
    -t "linhbngo/onering-amd64:${topic}" \
    docker/
done

echo "Done. Start with: docker compose up -d ide system-programming ..."
