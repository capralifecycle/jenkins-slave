#!/bin/sh
# Build and test similar to in CI
set -eux

docker build --pull -t jenkins-slave-modern-v2 -f ./modern-v2/Dockerfile .
docker run \
  --rm \
  -it \
  -e IS_TEST=1 \
  -v "$PWD:/data" \
  -w /data \
  -u root \
  --entrypoint= \
  --privileged \
  jenkins-slave-modern-v2 \
  sh -c './jenkins/test-modern-v2.sh'
