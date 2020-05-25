FROM docker:19-dind@sha256:61d1e32a4d419a79e047feed2388af2e557661ea0491b3f6408b2c90e007c5a5

# py3-paramiko and py3-cffi is for docker compose installed later
# see https://github.com/docker/compose/issues/6617#issuecomment-478662098

RUN set -eux; \
    apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      make \
      openjdk8-jre \
      openssh-client \
      openssl \
      py3-cffi \
      py3-paramiko \
      py3-pip \
      su-exec \
      supervisor \
      tar \
      zip \
    ; \
    pip3 install \
      awscli \
      docker-compose \
    ; \
    addgroup docker; \
    \
    # Make bash default shell
    ln -sf /bin/bash /bin/sh

# Set DOCKER_HOST so that it will not be dependent on what happens in the
# docker own entrypoint script.
ENV DOCKER_HOST=unix:///var/run/docker.sock

# install Jenkins slave
# inspiration: https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/Dockerfile
# see https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
ENV JENKINS_SWARM_VERSION 3.12

RUN set -eux; \
    adduser -D -u 1000 -G docker jenkins; \
    chown -R jenkins /home/jenkins; \
    curl --create-dirs -sSLo \
      /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
      https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
    ; \
    chmod 755 /usr/share/jenkins

# Ensure JVM uses cgroups for memory limits due to running as a container
ENV JAVA_TOOL_OPTIONS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dsun.zip.disableMemoryMapping=true"

COPY wrapper/container/* /
COPY modern-v2/run-jenkins-slave.sh /

CMD ["/run.sh"]
