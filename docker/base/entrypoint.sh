#!/bin/bash
# If a command was passed (e.g. whoami for tests), run it and exit.
if [ $# -gt 0 ]; then
  exec "$@"
fi
# Otherwise run as a service: ensure sshd can start, then start it.
sudo mkdir -p /run/sshd
exec sudo /usr/sbin/sshd -D -e
