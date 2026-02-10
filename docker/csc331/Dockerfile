# Standalone course image: no base image, no IDE. Sharing via volumes only.
FROM --platform=linux/amd64 ubuntu:24.04 AS stage-amd64
FROM --platform=linux/arm64/v8 ubuntu:24.04 AS stage-arm64
ARG TARGETARCH
FROM stage-${TARGETARCH} AS final

USER root

# Build context ./docker so we can use base.config for consistent user (uid 1001)
COPY base/base.config /build/
COPY csc331/install.sh /build/
COPY csc331/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 755 /build/install.sh /usr/local/bin/entrypoint.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
