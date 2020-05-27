#!/bin/sh
set -eu

# This uses the socker that is set up in test-dind.sh.

user_gid=$(id -g)
docker_gid=$(stat -c %g /docker.sock)

echo "Running as: $(id)"
echo "Docker GID: $docker_gid"

if [ "$user_gid" != "$docker_gid" ]; then
  echo "ERROR: User GID and docker GID not same"
  exit 1
fi

if [ "$docker_gid" != "1000" ]; then
  echo "ERROR: Expected GID to be 1000"
  exit 1
fi

./jenkins/test-slave-expectations.sh
