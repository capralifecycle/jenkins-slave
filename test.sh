#!/bin/sh
# Build and test similar to in CI
set -eux

docker build --pull -t jenkins-slave-wrapper .
docker run \
  --rm \
  -it \
  -v "$PWD:/data" \
  -w /data \
  -u root \
  --entrypoint= \
  --privileged \
  jenkins-slave-wrapper \
  sh -c './jenkins/test-dind.sh'
