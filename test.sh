#!/bin/sh
# Build and test similar to in CI
set -eux

for model in modern classic classic-java-11; do
  echo "Testing $model"

  docker build -t jenkins-slave-$model -f ./$model/Dockerfile .
  docker run \
    --rm \
    -it \
    -v "$PWD:/data" \
    -w /data \
    -u root \
    --entrypoint= \
    jenkins-slave \
    sh -c './jenkins/test-image.sh'
done
