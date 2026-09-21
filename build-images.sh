#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose build
echo "Start with:  docker compose up -d --scale spark-worker=3"
