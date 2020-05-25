#!/bin/sh
set -e

export DOCKER_HOST=unix:///docker.sock

# Spawn Docker daemon
/run-docker.sh test &

# Wait til Docker is available
for x in $(seq 1 10); do
  if docker info; then
    break
  fi

  sleep 1
done

# Spawn hello world container
docker run --rm hello-world

docker_gid=$(stat -c %g /docker.sock)
echo "Docker socket group: $docker_gid"

if [ "$docker_gid" != "1000" ]; then
  echo "ERROR: GID was expected to be 1000 (same as jenkins group in slave)"
  exit 1
fi
