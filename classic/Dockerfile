# inspiration:
# - https://github.com/jenkinsci/docker-workflow-plugin/tree/master/demo
FROM openjdk:8-jdk-alpine@sha256:6d48c413a989b91d60f0f557f20dcc12280c60049168044dfd4fbab64fbf06d4

# py3-paramiko and py3-cffi is for docker compose installed later
# see https://github.com/docker/compose/issues/6617#issuecomment-478662098
RUN apk add --no-cache \
             ca-certificates \
             curl \
             git \
             openssh-client \
             openssl \
             procps \
             py3-pip \
             py3-paramiko \
             py3-cffi \
             su-exec \
             tar \
    && pip3 install awscli

# install Docker client
# reference: https://github.com/docker-library/docker/blob/cf3d3343f291146f9b79ccafa725a9bb28257ea0/18.03/Dockerfile
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 18.03.1-ce

RUN set -x \
    && curl -fSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    # TODO: not currently supported, see reference
    #&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar \
        --extract \
        --file docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/ \
    && rm docker.tgz \
    \
    # install docker compose
    && pip3 install docker-compose

# install Jenkins slave
# inspiration: https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/Dockerfile
# see https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
ENV JENKINS_SWARM_VERSION 3.12

RUN addgroup jenkins \
    && adduser -D -u 1000 -G jenkins jenkins \
    && chown -R jenkins /home/jenkins \
    && curl --create-dirs -sSLo \
          /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
          https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
    && chmod 755 /usr/share/jenkins

# Setup below is additional tools used due to builds not building in Docker
# requiring these tools to be installed in the slave itself.

RUN set -eux; \
    apk add --no-cache \
        bash \
        btrfs-progs \
        e2fsprogs-extra \
        fontconfig \
        gettext \
        groff \
        iptables \
        jq \
        less \
        make \
        maven \
        npm \
        nodejs \
        py2-pip \
        python \
        supervisor \
        ttf-dejavu \
        xz \
        yarn \
    ; \
    \
    # AWS stuff
    curl -fSL "https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest" -o /usr/local/bin/ecs-cli; \
    chmod +x /usr/local/bin/ecs-cli; \
    curl -fSL https://raw.githubusercontent.com/silinternational/ecs-deploy/develop/ecs-deploy -o /usr/local/bin/ecs-deploy; \
    chmod +x /usr/local/bin/ecs-deploy; \
    \
    # Make bash default shell
    ln -sf /bin/bash /bin/sh; \
    \
    # Dont check host keys when connecting with ssh (Git) from the docker container
    sed -i 's/#   StrictHostKeyChecking .*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config

# Ensure JVM uses cgroups for memory limits due to running as a container
ENV JAVA_TOOL_OPTIONS "-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Dsun.zip.disableMemoryMapping=true"

VOLUME ["/home/jenkins/"]

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
