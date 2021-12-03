FROM azul/zulu-openjdk-alpine:11@sha256:0d3fd9e4b8c584d4d11f94188bf1b52e973db7c0b1d4407e8578d1d8feec3d54

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
ENV JENKINS_SWARM_TAG_VERSION=swarm-plugin-3.28

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
