#!/bin/sh
# Build and test similar to in CI
set -eux

docker build -t jenkins-slave-wrapper -f ./wrapper/Dockerfile .
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
