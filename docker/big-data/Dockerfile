# Topic: big data. FROM base; normal Spack workflow, reads from spack-mirror at build.
FROM linhbngo/onering-amd64:base
ENV SPACK_ROOT=/opt/spack

USER root
COPY spack/bootstrap.sh /build/
COPY big-data/install.sh /build/

RUN --mount=type=bind,source=spack-mirror-cache,target=/opt/spack-mirror \
    chmod 755 /build/bootstrap.sh /build/install.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
