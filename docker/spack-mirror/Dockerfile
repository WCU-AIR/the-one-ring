# Spack mirror service: uses spack-stack image and pushes its installs to a volume.
# No build; use spack-stack image and run populate.sh to fill the mirror volume.
FROM linhbngo/onering-amd64:spack-stack

USER root
COPY spack-mirror/populate.sh /usr/local/bin/populate-spack-mirror.sh
RUN chmod 755 /usr/local/bin/populate-spack-mirror.sh
ENTRYPOINT ["/usr/local/bin/populate-spack-mirror.sh"]
