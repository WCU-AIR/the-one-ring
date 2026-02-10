# Topic: system programming. Builds on spack-stack; topic-specific bits + profile.d.
FROM linhbngo/onering-amd64:spack-stack

USER root
COPY system-programming/install.sh /build/

RUN chmod 755 /build/install.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
