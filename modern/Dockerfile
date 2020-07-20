# inspiration:
# - https://github.com/jenkinsci/docker-workflow-plugin/tree/master/demo
FROM openjdk:8-jre-alpine@sha256:b2ad93b079b1495488cc01375de799c402d45086015a120c105ea00e1be0fd52

# py3-paramiko and py3-cffi is for docker compose installed later
# see https://github.com/docker/compose/issues/6617#issuecomment-478662098
RUN apk add --no-cache \
             bash \
             ca-certificates \
             curl \
             git \
             make \
             jq \
             openssh-client \
             openssl \
             py3-pip \
             py3-paramiko \
             py3-cffi \
             su-exec \
             tar \
             zip \
    && pip3 install awscli \
    \
    # Make bash default shell
    && ln -sf /bin/bash /bin/sh

# install Docker client and Docker Compose
RUN set -eux; \
    wget https://raw.githubusercontent.com/capralifecycle/buildtools-snippets/master/tools/docker/install.sh -O /tmp/script.sh; \
    sh /tmp/script.sh; \
    rm /tmp/script.sh; \
    docker --version; \
    \
    # install docker compose
    pip3 install docker-compose

# install Jenkins slave
# inspiration: https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/Dockerfile
# see https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
# renovate: datasource=github-releases depName=jenkinsci/swarm-plugin versioning=regex:^swarm-plugin-(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?$
ENV JENKINS_SWARM_VERSION=3.12

RUN addgroup jenkins \
    && adduser -D -u 1000 -G jenkins jenkins \
    && chown -R jenkins /home/jenkins \
    && curl --create-dirs -sSLo \
          /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
          https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
    && chmod 755 /usr/share/jenkins

# Ensure JVM uses cgroups for memory limits due to running as a container
ENV JAVA_TOOL_OPTIONS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dsun.zip.disableMemoryMapping=true"

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
