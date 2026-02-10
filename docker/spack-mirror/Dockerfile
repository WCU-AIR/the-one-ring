# Spack mirror service: FROM base; installs Spack + curated packages into the image.
# When the container runs with the mirror volume mounted, entrypoint pushes buildcache to it.
FROM linhbngo/onering-amd64:base

USER root
COPY spack/bootstrap.sh /build/
COPY spack-mirror/install.sh /build/
COPY spack-mirror/populate.sh /usr/local/bin/populate-spack-mirror.sh
COPY spack-mirror/packages.txt /build/

RUN chmod 755 /build/bootstrap.sh /build/install.sh /usr/local/bin/populate-spack-mirror.sh && \
    /build/install.sh && rm -rf /build

USER root
ENTRYPOINT ["/usr/local/bin/populate-spack-mirror.sh"]
