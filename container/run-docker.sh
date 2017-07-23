#!/bin/sh
# This file do the same work as the entrypoint of the dind image.
# See https://github.com/docker-library/docker/blob/master/17.03/dind/dockerd-entrypoint.sh
# (However we don't pass any arguments here.)
set -e

set -- dockerd \
  --host=unix:///var/run/docker.sock \
  --host=tcp://0.0.0.0:2375 \
  --storage-driver=vfs

exec "$@"
