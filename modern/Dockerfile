# inspiration:
# - https://github.com/jenkinsci/docker-workflow-plugin/tree/master/demo
FROM azul/zulu-openjdk-alpine:11.0.21-jre@sha256:803f0d1d9958fdd9a009e007711f7e7eeba794e0f09c2a85b5b11a50b6429770

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

# renovate: datasource=github-releases depName=docker/compose extractVersion=v(?<version>.*)$
ENV DOCKER_COMPOSE_VERSION=2.23.0
# install Docker client and Docker Compose
RUN set -eux; \
    wget https://raw.githubusercontent.com/capralifecycle/buildtools-snippets/master/tools/docker/install.sh -O /tmp/script.sh; \
    sh /tmp/script.sh; \
    rm /tmp/script.sh; \
    docker --version; \
    \
    # install docker compose v2
    DOCKER_CLI_PLUGIN_PATH=/usr/local/lib/docker/cli-plugins; \
    mkdir -p "$DOCKER_CLI_PLUGIN_PATH"; \
    curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o "$DOCKER_CLI_PLUGIN_PATH/docker-compose"; \
    chmod +x "$DOCKER_CLI_PLUGIN_PATH/docker-compose"; \
    ln -s  "$DOCKER_CLI_PLUGIN_PATH/docker-compose" /usr/local/bin/docker-compose; \
    docker-compose --version

# install Jenkins slave
# inspiration: https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/Dockerfile
# see https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
# renovate: datasource=github-releases depName=jenkinsci/swarm-plugin versioning=regex:^swarm-plugin-(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?$
ENV JENKINS_SWARM_TAG_VERSION=swarm-plugin-3.40

RUN JENKINS_SWARM_VERSION=${JENKINS_SWARM_TAG_VERSION##*-} \
    && addgroup jenkins \
    && adduser -D -u 1000 -G jenkins jenkins \
    && chown -R jenkins /home/jenkins \
    && curl --create-dirs -sSLo \
          /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
          https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
    && chmod 755 /usr/share/jenkins

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
