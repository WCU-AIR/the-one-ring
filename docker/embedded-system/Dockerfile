# Topic: embedded systems. Builds on spack-stack; apt for cross-compilers + profile.d.
FROM linhbngo/onering-amd64:spack-stack

USER root
COPY embedded-system/install.sh /build/

RUN chmod 755 /build/install.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
