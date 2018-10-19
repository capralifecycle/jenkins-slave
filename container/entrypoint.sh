#!/bin/sh
# inspired by https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/jenkins-slave.sh
set -eu

# Add jenkins user to group owning Docker socket
if [ -e /var/run/docker.sock ]; then
    gid=$(stat -c %g /var/run/docker.sock)

    if [ -e /etc/alpine-release ]; then
        addgroup -g $gid docker 2>/dev/null || :
        adduser jenkins docker || :
    else
        groupadd -g $gid docker 2>/dev/null || :
        usermod -aG docker jenkins || :
    fi
fi

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

    gosu jenkins java ${JAVA_OPTS:-} -jar $jar -fsroot "/home/jenkins" "$@"
else
    gosu jenkins "$@"
fi
