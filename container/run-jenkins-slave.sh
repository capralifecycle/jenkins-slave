#!/bin/sh
# This file runs the Jenkins slave as a Docker container inside this
# container. The alternative would be to embed Java 8 and the slave
# binary as part of this image - but by not doing so we seperate concerns
# and avoid complexity.
set -e

# Docker might not have started yet, as it is being initialized at the same
# time as this is run.
for x in $(seq 1 10); do
  if docker info; then
    break
  fi

  sleep 1
done

for varname in JENKINS_MASTER_USERNAME JENKINS_MASTER_PASSWORD; do
  eval vartest=\$$varname
  if [ -z "$vartest" ]; then
      echo "Missing $varname environment variable"
      exit 1
  fi
done

MASTER=http://jenkins-internal.capra.tv

# TODO: provide this in a more safe way
USER=$JENKINS_MASTER_USERNAME
PASS=$JENKINS_MASTER_PASSWORD

# Log in to ECR using task role that gives permission
eval $(aws ecr get-login --no-include-email --region eu-central-1)

# Run the slave
# TODO: group as docker socket
# TODO: access to download repo?
image=923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/slave
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  $image \
    -disableSslVerification \
    -master "$MASTER" \
    -labels "docker" \
    -username "$USER" \
    -password "$PASS" \
    -name "docker" \
    -executors 1
