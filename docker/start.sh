#!/bin/bash
set -eo pipefail

export SPARK_HOME="${SPARK_HOME:-/opt/spark}"
ROLE="${1:-master}"

if [ "$ROLE" = "worker" ]; then
  SPARK_MASTER="${SPARK_MASTER:-spark://spark-master:7077}"
  echo "Joining ${SPARK_MASTER} with ${SPARK_WORKER_CORES:-1} core(s) and ${SPARK_WORKER_MEMORY:-1G} memory"
  exec "${SPARK_HOME}/bin/spark-class" \
    org.apache.spark.deploy.worker.Worker \
    --webui-port "${SPARK_WORKER_WEBUI_PORT:-8081}" \
    --cores "${SPARK_WORKER_CORES:-1}" \
    --memory "${SPARK_WORKER_MEMORY:-1G}" \
    "${SPARK_MASTER}"
fi

export SPARK_MASTER_HOST="${SPARK_MASTER_HOST:-spark-master}"

jupyter lab \
  --ip=0.0.0.0 \
  --port="${JUPYTER_PORT:-8888}" \
  --no-browser \
  --allow-root \
  --IdentityProvider.token="${JUPYTER_TOKEN:-}" \
  --ServerApp.password="" \
  --ServerApp.allow_origin="*" \
  --ServerApp.root_dir="${JUPYTER_NOTEBOOK_DIR:-/opt/spark-apps}" \
  &

echo "Jupyter Server on :${JUPYTER_PORT:-8888}  master spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT:-7077}"

exec "${SPARK_HOME}/bin/spark-class" \
  org.apache.spark.deploy.master.Master \
  --host "${SPARK_MASTER_HOST}" \
  --port "${SPARK_MASTER_PORT:-7077}" \
  --webui-port "${SPARK_MASTER_WEBUI_PORT:-8080}"
