FROM docker:19-dind@sha256:5b45c3565b02cb453fc0ef33e3d082006293d5d002d9cfd06d6ff290724c2d37

# py3-paramiko and py3-cffi is for docker compose installed later
# see https://github.com/docker/compose/issues/6617#issuecomment-478662098

RUN set -eux; \
    apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      jq \
      openjdk8-jre \
      openssh-client \
      openssl \
      py3-cffi \
      py3-paramiko \
      py3-pip \
      su-exec \
      supervisor \
      tar \
    ; \
    pip3 install \
      awscli \
      docker-compose \
    ; \
    addgroup docker

# Set DOCKER_HOST so that it will not be dependent on what happens in the
# docker own entrypoint script.
ENV DOCKER_HOST=unix:///var/run/docker.sock

# install Jenkins slave
# inspiration: https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/Dockerfile
# see https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
ENV JENKINS_SWARM_VERSION 3.12

RUN set -eux; \
    addgroup jenkins; \
    adduser -D -u 1000 -G jenkins jenkins; \
    addgroup jenkins docker; \
    chown -R jenkins /home/jenkins; \
    curl --create-dirs -sSLo \
      /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
      https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
    ; \
    chmod 755 /usr/share/jenkins

# Ensure JVM uses cgroups for memory limits due to running as a container
ENV JAVA_TOOL_OPTIONS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dsun.zip.disableMemoryMapping=true"

VOLUME ["/home/jenkins/"]

COPY wrapper/container/* /
COPY modern-v2/run-jenkins-slave.sh /

CMD ["/run.sh"]
