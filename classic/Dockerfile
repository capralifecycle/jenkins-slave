# inspiration:
# - https://github.com/jenkinsci/docker-workflow-plugin/tree/master/demo
FROM openjdk:8-jdk-alpine

RUN apk add --no-cache \
             ca-certificates \
             curl \
             git \
             openssh-client \
             openssl \
             py-pip \
             tar \
    && pip install awscli

# install gosu
# reference: https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.10
RUN set -ex; \
    \
    apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
    ; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
    # verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc || :; \
    \
    chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
    gosu nobody true; \
    \
    apk del .gosu-deps

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
    && pip install docker-compose

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
        nodejs \
        py2-pip \
        python \
        supervisor \
        ttf-dejavu \
        xz \
        yarn \
    ; \

    # AWS stuff
    curl -fSL "https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest" -o /usr/local/bin/ecs-cli; \
    chmod +x /usr/local/bin/ecs-cli; \
    curl -fSL https://raw.githubusercontent.com/silinternational/ecs-deploy/develop/ecs-deploy -o /usr/local/bin/ecs-deploy; \
    chmod +x /usr/local/bin/ecs-deploy; \

    # Make bash default shell
    ln -sf /bin/bash /bin/sh

VOLUME ["/home/jenkins/"]

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
