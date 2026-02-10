# Spack stack base: Spack + curated packages. Topic services FROM this image.
FROM linhbngo/onering-amd64:base

USER root
COPY spack/bootstrap.sh /build/
COPY spack-stack/install.sh /build/
COPY spack-stack/spack-packages.txt /build/

RUN chmod 755 /build/bootstrap.sh /build/install.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
