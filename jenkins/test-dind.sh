#!/bin/sh
set -e

export DOCKER_HOST=unix:///docker.sock

# Spawn Docker daemon
/run-docker.sh &

# Wait til Docker is available
for x in $(seq 1 10); do
  if docker info; then
    break
  fi

  sleep 1
done

# Spawn hello world container
docker run --rm hello-world
