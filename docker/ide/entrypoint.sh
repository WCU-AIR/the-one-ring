#!/bin/bash
if [ -z "$(ls -A /home/student 2>/dev/null)" ]; then
  echo "Initializing shared home from skeleton..."
  cp -R /opt/home/student/. /home/student/
  chmod -R u=rwX,go= /home/student 2>/dev/null || true
fi
exec code-server --bind-addr 0.0.0.0:8088
