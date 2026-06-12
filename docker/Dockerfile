FROM --platform=linux/amd64 ubuntu:24.04

USER root

COPY . /build
RUN chmod -R 755 /build/*.sh && /build/install.sh && rm -rf /build
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
