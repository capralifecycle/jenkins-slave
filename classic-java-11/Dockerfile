FROM azul/zulu-openjdk-alpine:11.0.21@sha256:b091fbc520d534840e00e2bda6bbb08a7342806970994fba998ba0d4164f2b31

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
        openssh-client \
        openssl \
        procps \
        py3-pip \
        py3-paramiko \
        py3-cffi \
        su-exec \
        tar \
        zip \
    ; \
    pip3 install awscli; \
    \
    # Make bash default shell
    ln -sf /bin/bash /bin/sh

# renovate: datasource=github-releases depName=docker/compose extractVersion=v(?<version>.*)$
ENV DOCKER_COMPOSE_VERSION=2.27.1
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
ENV JENKINS_SWARM_TAG_VERSION=swarm-plugin-3.44

RUN set -eux; \
    JENKINS_SWARM_VERSION=${JENKINS_SWARM_TAG_VERSION##*-}; \
    addgroup jenkins; \
    adduser -D -u 1000 -G jenkins jenkins; \
    chown -R jenkins /home/jenkins; \
    curl --create-dirs -sSLo \
        /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
        https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
    ; \
    chmod 755 /usr/share/jenkins

# Setup below is additional tools used due to builds not building in Docker
# requiring these tools to be installed in the slave itself.

RUN set -eux; \
    apk add --no-cache \
        btrfs-progs \
        e2fsprogs-extra \
        fontconfig \
        gettext \
        groff \
        iptables \
        less \
        npm \
        nodejs \
        supervisor \
        ttf-dejavu \
        # xmlstarlet is used to extract data from pom.xml
        xmlstarlet \
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
    # Dont check host keys when connecting with ssh (Git) from the docker container
    sed -i 's/#   StrictHostKeyChecking .*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config

RUN set -eux; \
    wget https://raw.githubusercontent.com/capralifecycle/buildtools-snippets/master/tools/maven-3/install.sh -O /tmp/script.sh; \
    sh /tmp/script.sh; \
    rm /tmp/script.sh; \
    mvn -version; \
    # Make Maven available on same path as in normal classic slave, and
    # the path that Jenkins expect.
    mkdir -p /usr/share/java; \
    ln -s /usr/share/maven /usr/share/java/maven-3; \
    test -x /usr/share/java/maven-3/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/home/jenkins/.m2"

# TODO: Unsure if this should remain enabled in JVM 11
# ENV JAVA_TOOL_OPTIONS "-Dsun.zip.disableMemoryMapping=true"

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
