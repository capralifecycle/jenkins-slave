#!/bin/bash
set -e -o pipefail

if [ -z "$IS_TEST" ]; then
  # Log in to AWS using task role that gives permission
  eval $(aws ecr get-login --no-include-email --region eu-central-1)

  # Get Jenkins credentials from parameters store
  USER=$(aws ssm get-parameters --region eu-central-1 --names /buildtools/jenkins-slave/username | jq -r .Parameters[0].Value)
  PASS=$(aws ssm get-parameters --region eu-central-1 --names /buildtools/jenkins-slave/password --with-decryption | jq -r .Parameters[0].Value)

  if [ -z "$USER" ] || [ -z "$PASS" ]; then
    echo "Username and/or password was not retrieved from SSM. Possibly missing credentials. Maybe you are not running this on ECS?"
    exit 1
  fi

  # Save password to file instead of passing as argument
  passfile=/run/jenkins-slave-password
  echo "$PASS" >$passfile

  # Schedule a deletion of the password after giving the
  # slave time to pick it up. This reduces the possibility that a
  # job can extract the password. Using a file to transport the
  # password also ensures it's not visible in `ps aux` or when
  # listing environment variables
  (
    sleep 60
    echo "Wiping slave credentials from disk"
    rm $passfile
  ) &
fi

# NOTE: We use MESOS_TASK_ID because the swarm client accepts it to use as a
# hash appended to the name. The default is to used the IP-adress which conflicts
# because we are running Docker-in-Docker.
# See https://github.com/jenkinsci/swarm-plugin/blob/1c7c42d88c4db78771020e0db18ea644b2286570/client/src/main/java/hudson/plugins/swarm/SwarmClient.java#L56
MESOS_TASK_ID="$(hostname)"
export MESOS_TASK_ID

jar=$(ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1)

if [ -z "$IS_TEST" ]; then
  # shellcheck disable=SC2086
  su-exec jenkins java ${JAVA_OPTS:-} \
    -jar "$jar" \
    -fsroot "/home/jenkins" \
    -disableSslVerification \
    -master "http://jenkins-internal.capra.tv" \
    -labels "$SLAVE_LABELS" \
    -username "$USER" \
    -passwordFile "$passfile" \
    -name "$SLAVE_NAME" \
    -executors "${SLAVE_EXECUTORS:-1}"
else
  su-exec jenkins java ${JAVA_OPTS:-} \
    -jar "$jar" \
    "$@"
fi
