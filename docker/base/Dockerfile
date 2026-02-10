# Minimal base: sudo, openssh-server, curl, shared user (uid 1001), generic entrypoint.
# All topic services and IDE build on this. Build context ./docker.
# amd64 only; on ARM/Mac use Docker's amd64 emulation.
FROM --platform=linux/amd64 ubuntu:24.04

USER root

COPY base/base.config base/install.sh base/entrypoint.sh /build/

RUN chmod 755 /build/*.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
