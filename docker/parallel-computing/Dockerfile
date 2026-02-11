# Topic: parallel computing. FROM base; Spack fetches sources from network. Shared store at /software.
FROM linhbngo/onering-amd64:base
ENV SPACK_ROOT=/opt/spack

USER root
COPY spack/bootstrap.sh /build/
COPY parallel-computing/install.sh /build/

# Mount shared Spack store at /software so installs are reused across topic builds and at runtime.
RUN --mount=type=bind,source=spack-store,target=/software,rw \
    chmod 755 /build/bootstrap.sh /build/install.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
