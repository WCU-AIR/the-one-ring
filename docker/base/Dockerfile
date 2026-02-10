# Minimal base: sudo, openssh-server, curl, shared user (uid 1001), generic entrypoint.
# All topic services and IDE build on this. Build context ./docker.
FROM --platform=linux/amd64 ubuntu:24.04 AS stage-amd64
FROM --platform=linux/arm64/v8 ubuntu:24.04 AS stage-arm64
ARG TARGETARCH
FROM stage-${TARGETARCH} AS final

USER root

COPY base/base.config base/install.sh base/entrypoint.sh /build/

RUN chmod 755 /build/*.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
