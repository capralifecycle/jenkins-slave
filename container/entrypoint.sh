#!/bin/sh
# inspired by https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/jenkins-slave.sh
set -eu

# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [ $# -lt 1 ]; then
  launcher=1
else
  case "$1" in
  -*) launcher=1 ;;
  *) launcher=0 ;;
  esac
fi

if [ $launcher -eq 1 ]; then
  jar=$(ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1)

  su-exec jenkins java ${JAVA_OPTS:-} -jar $jar -fsroot "/home/jenkins" "$@"
else
  su-exec jenkins "$@"
fi
