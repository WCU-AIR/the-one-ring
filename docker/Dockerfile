FROM apache/spark:4.2.0

USER root

ENV SPARK_HOME=/opt/spark \
    PYSPARK_PYTHON=python3 \
    PYSPARK_DRIVER_PYTHON=python3 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=1 \
    JUPYTER_PORT=8888 \
    JUPYTER_NOTEBOOK_DIR=/opt/spark-apps \
    PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9.9-src.zip:/opt/spark/python/lib/pyspark.zip

# curl: compose healthcheck. python3/pip already ship on apache/spark:4.2.0.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sfn /opt/spark /spark \
    && ln -sfn /usr/bin/python3 /usr/bin/python

# JupyterLab: launched by start.sh on the spark-master role at deploy time,
# listens on 0.0.0.0:8888 with no token/password, rooted at /opt/spark-apps.
RUN pip3 install --no-cache-dir jupyterlab==4.3.5

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

COPY spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf
COPY --chmod=755 start.sh /opt/spark-cluster/start.sh

WORKDIR /opt/spark-apps
# 8080: master UI, 7077: master RPC, 8888: JupyterLab, 4040: app UI, 8081: worker UI
EXPOSE 8080 7077 8888 4040 8081

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/opt/spark-cluster/start.sh", "master"]
