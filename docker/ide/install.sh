#!/bin/bash
set -e

# Base already has curl, sudo, user; only add code-server and skeleton
sh /build/code-server.sh --prefix=/usr/local
cp -R /build/home /opt/
