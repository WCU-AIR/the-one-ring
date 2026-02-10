#!/bin/bash
echo "---> Starting sshd on the node..."
sudo /usr/sbin/sshd -e
# Keep container running; no code-server
exec sleep infinity
 