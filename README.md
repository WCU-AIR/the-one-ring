# Spark Cluster with Docker Compose

A Spark 4.2.0 standalone cluster for teaching and local development. One image (`spark-master:4.2.0`, from [`apache/spark:4.2.0`](https://hub.docker.com/r/apache/spark)) runs the master plus Jupyter Server. Workers use that same image and register on `spark://spark-master:7077`.

| Service | Role |
| --- | --- |
| `spark-master` | Spark master, Jupyter Server (Lab), PySpark driver |
| `spark-worker` | Spark worker; scale this service to add nodes |

## Prerequisites

* [Docker](https://docs.docker.com/get-docker/) with Compose v2 (`docker compose version`)
* Enough RAM for the master plus `N × SPARK_WORKER_MEM_LIMIT` (defaults assume about 1G per worker)

## Build

From the repository root:

```sh
docker compose build --no-cache
```

Or:

```sh
./build-images.sh
```

Both build `spark-master:4.2.0` from `docker/Dockerfile`. Rebuild after you change anything under `docker/` (Dockerfile, `start.sh`, `requirements.txt`, or `spark-defaults.conf`).

## Deploy

1. Optional: edit `.env` for cores, memory, and host ports (see below).
2. Start the cluster. Change `3` to the worker count you want:

```sh
docker compose up -d --scale spark-worker=3
```

Compose builds the image first if it is missing. To force a rebuild on deploy:

```sh
docker compose up -d --build --scale spark-worker=3
```

3. Wait until the master is healthy and workers have started:

```sh
docker compose ps
```

`spark-master` should show `healthy`. Each `spark-worker` should be `Up`. Workers join only after the master healthcheck passes.

4. Confirm the UIs:

| URL | What you should see |
| --- | --- |
| http://localhost:8888 | Jupyter Lab; notebooks from `./apps` |
| http://localhost:9090 | Spark master UI; your workers listed as **Alive** |
| http://localhost:4040 | Spark application UI (only while a job is running) |

Worker UIs listen on container port `8081`. Docker maps each replica to a random host port. List them with `docker compose ps`.

### Logs

```sh
docker compose logs -f spark-master
docker compose logs -f spark-worker
```

### Scale after the cluster is already up

```sh
docker compose up -d --scale spark-worker=5
```

New workers register with the master on their own. Scaling down removes extra worker containers.

### Recreate after changing `.env`

Environment variables are applied at container create time:

```sh
docker compose up -d --force-recreate --scale spark-worker=3
```

## Configure cores, memory, and ports

Edit `.env` in the repository root. Defaults:

| Variable | Default | Purpose |
| --- | --- | --- |
| `SPARK_WORKER_CORES` | `1` | Cores each worker offers Spark |
| `SPARK_WORKER_MEMORY` | `1G` | Memory each worker offers Spark |
| `SPARK_DRIVER_MEMORY` | `1G` | Driver heap (Jupyter / spark-submit) |
| `SPARK_EXECUTOR_MEMORY` | `1G` | Executor heap |
| `SPARK_WORKER_CPU_LIMIT` | `1.0` | Docker CPU limit per worker container |
| `SPARK_WORKER_MEM_LIMIT` | `1G` | Docker memory limit per worker container |
| `SPARK_MASTER_UI_PORT` | `9090` | Host port for the Spark master UI |
| `SPARK_MASTER_PORT` | `7077` | Host port for the Spark master RPC port |
| `JUPYTER_PORT` | `8888` | Host port for Jupyter |
| `SPARK_APP_UI_PORT` | `4040` | Host port for the Spark application UI |
| `JUPYTER_TOKEN` | empty | Set a token to require login at Jupyter |

Example: 2 cores and 2G per worker:

```env
SPARK_WORKER_CORES=2
SPARK_WORKER_MEMORY=2G
SPARK_WORKER_CPU_LIMIT=2.0
SPARK_WORKER_MEM_LIMIT=2G
```

Keep `SPARK_WORKER_MEMORY` at or below `SPARK_WORKER_MEM_LIMIT` so Spark does not advertise more RAM than Docker allows.

## Use the cluster

Jupyter and PySpark already target `spark://spark-master:7077` (`docker/spark-defaults.conf`). In a notebook:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("demo").getOrCreate()
spark.sparkContext.defaultParallelism
```

Course notebooks that set `SPARK_HOME` to `/spark` still work: `/spark` is a symlink to `/opt/spark`.

Shared directories:

| Host | Container | Purpose |
| --- | --- | --- |
| `./apps` | `/opt/spark-apps` | Notebooks, jars, application code |
| `./data` | `/opt/spark-data` | Input data on every node |

Submit a jar from the master (place the file under `./apps` first):

```sh
docker exec spark-master /opt/spark/bin/spark-submit \
  --master spark://spark-master:7077 \
  --class org.example.App \
  /opt/spark-apps/your-app.jar
```

## Stop

```sh
docker compose down
```

Add `-v` only if you also want Compose-managed volumes removed. Bind mounts (`./apps`, `./data`) are left as-is.
