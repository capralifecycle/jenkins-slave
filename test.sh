#!/bin/sh
# Build and test similar to in CI
set -eux

docker build -t jenkins-slave .
docker run \
  --rm \
  -it \
  -v "$PWD:/data" \
  -w /data \
  -u root \
  --entrypoint= \
  jenkins-slave \
  sh -c './jenkins/test-image.sh'
