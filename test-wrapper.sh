#!/bin/sh
# Build and test similar to in CI
set -eux

docker build --pull -t jenkins-slave-wrapper -f ./wrapper/Dockerfile .
docker run \
  --rm \
  -it \
  -v "$PWD:/data" \
  -w /data \
  -u root \
  --entrypoint= \
  --privileged \
  jenkins-slave-wrapper \
  sh -c './wrapper/jenkins/test-dind.sh'
