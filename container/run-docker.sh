#!/bin/sh
# This file do the same work as the entrypoint of the dind image.
# See https://github.com/docker-library/docker/blob/master/17.03/dind/dockerd-entrypoint.sh
# (However we don't pass any arguments here.)
set -e

# Use overlay2 file system as it should perform better than vfs that
# is the default of dind. On AWS using ECS optimized AMI we need to
# load the overlay module on the EC2 instance first for this to work:
#
#   modprobe overlay

set -- dockerd \
  --host=unix:///var/run/docker.sock \
  --host=tcp://0.0.0.0:2375 \
  --storage-driver=overlay2

exec "$@"
