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

Clone the repository branch:

```sh
git config --global core.autocrlf false 
git clone -b csc467 https://github.com/ngo-classes/the-one-ring
cd the-one-ring
```

From the repository root:

```sh
docker compose build --no-cache
```

to build `spark-master:4.2.0` from `docker/Dockerfile`. Rebuild after you change anything under `docker/` (Dockerfile, `start.sh`, `requirements.txt`, or `spark-defaults.conf`).

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

Example: 2 cores and 2G per worker:

```env
SPARK_WORKER_CORES=2
SPARK_WORKER_MEMORY=2G
SPARK_WORKER_CPU_LIMIT=2.0
SPARK_WORKER_MEM_LIMIT=2G
```

Keep `SPARK_WORKER_MEMORY` at or below `SPARK_WORKER_MEM_LIMIT` so Spark does not advertise more RAM than Docker allows.

## Use the cluster

Open [http://localhost:8888](http://localhost:8888) — JupyterLab loads with no login prompt (token and password are disabled at start) and its file browser is rooted at `/opt/spark-apps`, which is the same directory as `./apps` on the host. Drop a `.ipynb` into `./apps/` and it shows up in the browser immediately.

The image already exports `SPARK_HOME=/opt/spark`, `PYTHONPATH` for `py4j`/`pyspark`, and installs `/opt/spark/conf/spark-defaults.conf` with `spark.master spark://spark-master:7077` plus `spark.driver.host spark-master`. That means a notebook cell can just do:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("demo").getOrCreate()
sc = spark.sparkContext          # RDD / low-level API entry point
sc.defaultParallelism            # e.g. total cores across live workers
```

`spark` is the DataFrame / SQL entry point; `sc` is the SparkContext for the RDD API used in the `intro-to-pyspark-*` notebooks. Both point at the same running application on `spark://spark-master:7077`.

No `sys.path.insert(...)`, no `os.environ['SPARK_HOME'] = ...`, no `setMaster(...)` required. If you need to override driver/executor memory or cores for a particular notebook, chain `.config("spark.executor.memory", "2g")` etc. onto the builder.

Preinstalled Python stack in the image (pinned in `docker/requirements.txt`, safe against PySpark 4.2's `pandas>=2.2.0,<3.0.0` / `pyarrow>=18.0.0` / `numpy>=1.21` requirements):

| Package | Version |
| --- | --- |
| jupyterlab | 4.3.5 |
| numpy | 2.1.3 |
| pandas | 2.2.3 |
| pyarrow | 18.1.0 |
| scipy | 1.14.1 |
| matplotlib | 3.9.4 |
| seaborn | 0.13.2 |
| flask | 3.0.3 |

Course notebooks that set `SPARK_HOME` to `/spark` still work: `/spark` is a symlink to `/opt/spark`.

Shared directories:

| Host | Container | Purpose |
| --- | --- | --- |
| `./apps` | `/opt/spark-apps` | Notebooks, jars, application code (JupyterLab root) |
| `./data` | `/opt/spark-data` | Input data on every node |

## Stop

```sh
docker compose down
```

Add `-v` only if you also want Compose-managed volumes removed. Bind mounts (`./apps`, `./data`) are left as-is.
