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

# Log in to AWS using task role that gives permission
eval $(aws ecr get-login --no-include-email --region eu-central-1)

# Get Jenkins credentials from parameters store
USER=$(aws ssm get-parameters --region eu-central-1 --names /buildtools/jenkins-slave/username | jq -r .Parameters[0].Value)
PASS=$(aws ssm get-parameters --region eu-central-1 --names /buildtools/jenkins-slave/password --with-decryption | jq -r .Parameters[0].Value)

# NOTE: We use MESOS_TASK_ID because the swarm client accepts it to use as a
# hash appended to the name. The default is to used the IP-adress which conflicts
# because we are running Docker-in-Docker.
# See https://github.com/jenkinsci/swarm-plugin/blob/1c7c42d88c4db78771020e0db18ea644b2286570/client/src/main/java/hudson/plugins/swarm/SwarmClient.java#L56

# SLAVE_LABELS, SLAVE_VERSION and JAVA_OPTS are passed as environment variables
# when running wrapper docker container

# Run the slave
image=923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/slave:${SLAVE_VERSION:-latest}
docker pull $image
docker run \
  -e MESOS_TASK_ID="$(hostname)" \
  -e JAVA_OPTS="$JAVA_OPTS" \
  -e AWS_CONTAINER_CREDENTIALS_RELATIVE_URI="$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  $image \
    -disableSslVerification \
    -master "http://jenkins-internal.capra.tv" \
    -labels "$SLAVE_LABELS" \
    -username "$USER" \
    -password "$PASS" \
    -name "docker" \
    -executors 1
