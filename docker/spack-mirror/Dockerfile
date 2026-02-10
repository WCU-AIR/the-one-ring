# Spack mirror service: FROM base; bootstraps Spack only (no package installs).
# When the container runs with the mirror volume mounted, entrypoint runs "spack mirror create"
# to populate the mirror with source tarballs only. Topic images then fetch from mirror and build locally.
FROM linhbngo/onering-amd64:base

# Required when building/running under Rosetta (amd64 emulation on Mac); harmless otherwise.
ENV SPACK_ROOT=/opt/spack

USER root
COPY spack/bootstrap.sh /build/
COPY spack-mirror/install.sh /build/
COPY spack-mirror/populate.sh /usr/local/bin/populate-spack-mirror.sh
COPY spack-mirror/packages.txt /build/

RUN chmod 755 /build/bootstrap.sh /build/install.sh /usr/local/bin/populate-spack-mirror.sh && \
    /build/install.sh && rm -rf /build

USER root
ENTRYPOINT ["/usr/local/bin/populate-spack-mirror.sh"]
