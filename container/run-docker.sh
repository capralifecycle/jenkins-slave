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

# We need to put the socket on a special non-default path due to
# the builds in jenkins normally forward-mount the existing docker
# socket, but we wan't to use the Docker-in-Docker socket!

set -- dockerd \
  --host=unix:///docker.sock \
  --host=tcp://0.0.0.0:2375 \
  --storage-driver=overlay2

exec "$@"
