# Topic: machine learning. Builds on spack-stack; profile.d only.
FROM linhbngo/onering-amd64:spack-stack

USER root
COPY machine-learning/install.sh /build/

RUN chmod 755 /build/install.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
