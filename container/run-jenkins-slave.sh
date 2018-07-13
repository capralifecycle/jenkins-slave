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

# Save password to file instead of passing as argument
passfile=/run/jenkins-slave-password
echo "$PASS" >$passfile

# NOTE: We use MESOS_TASK_ID because the swarm client accepts it to use as a
# hash appended to the name. The default is to used the IP-adress which conflicts
# because we are running Docker-in-Docker.
# See https://github.com/jenkinsci/swarm-plugin/blob/1c7c42d88c4db78771020e0db18ea644b2286570/client/src/main/java/hudson/plugins/swarm/SwarmClient.java#L56

# Environment variables passed when running wrapper docker container:
# - JAVA_OPTS
# - SLAVE_EXECUTORS
# - SLAVE_LABELS
# - SLAVE_VERSION

# Pull image we will be running
tag=${SLAVE_VERSION:-latest}
image=923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-slave:$tag
docker pull $image

# Schedule a deletion of the password after giving the
# slave time to pick it up. This reduces the possibility that a
# job can extract the password. Using a file to transport the
# password also ensures it's not visible in `ps aux` or when
# listing environment variables
(
  sleep 5
  rm $passfile
) &

# Run the slave
docker run \
  -e MESOS_TASK_ID="$(hostname)" \
  -e JAVA_OPTS="$JAVA_OPTS" \
  -e AWS_CONTAINER_CREDENTIALS_RELATIVE_URI="$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $passfile:$passfile \
  $image \
    -disableSslVerification \
    -master "http://jenkins-internal.capra.tv" \
    -labels "$SLAVE_LABELS" \
    -username "$USER" \
    -passwordFile "$passfile" \
    -name "$tag" \
    -executors "${SLAVE_EXECUTORS:-1}"
