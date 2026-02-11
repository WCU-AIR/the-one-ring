# IDE (code-server). Builds on base (sudo, ssh, user); adds code-server and skeleton home.
FROM linhbngo/onering-amd64:base

USER root

COPY base/home /build/home/
COPY ide/code-server.sh /build/
COPY ide/install.sh /build/
COPY ide/entrypoint.sh /usr/local/bin/ide-entrypoint.sh

RUN chmod 755 /build/install.sh /usr/local/bin/ide-entrypoint.sh && /build/install.sh && rm -rf /build

USER student
ENTRYPOINT ["/usr/local/bin/ide-entrypoint.sh"]
