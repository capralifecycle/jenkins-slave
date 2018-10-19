# Currenly no Alpine version of OpenJDK through "official" channels
# (See https://github.com/docker-library/openjdk/issues/211)
FROM openjdk:11-jdk-slim

RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        curl \
        git \
        gosu \
        openssh-client \
        python-pip \
        python-setuptools \
    ; \
    pip install awscli; \
    rm -rf /var/lib/apt/lists/*

# install Docker client
# reference: https://github.com/docker-library/docker/blob/cf3d3343f291146f9b79ccafa725a9bb28257ea0/18.03/Dockerfile
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 18.03.1-ce

RUN set -eux; \
    curl -fSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz; \
    # TODO: not currently supported, see reference
    #echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c -; \
    tar \
        --extract \
        --file docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/; \
    rm docker.tgz; \
    \
    # install docker compose
    pip install docker-compose

# install Jenkins slave
# inspiration: https://github.com/carlossg/jenkins-swarm-slave-docker/blob/master/Dockerfile
# see https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
ENV JENKINS_SWARM_VERSION 3.12

RUN set -eux; \
    groupadd jenkins; \
    useradd -m -g jenkins jenkins; \
    curl --create-dirs -sSLo \
        /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar \
        https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar; \
    chmod 755 /usr/share/jenkins

# Setup below is additional tools used due to builds not building in Docker
# requiring these tools to be installed in the slave itself.

RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        btrfs-progs \
        fontconfig \
        gettext \
        groff \
        iptables \
        jq \
        less \
        make \
        maven \
        npm \
        supervisor \
        ttf-dejavu \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    npm install -g yarn; \
    \
    # Make Maven available on same path as in normal classic slave, and
    # the path that Jenkins expect.
    ln -s /usr/share/maven /usr/share/java/maven-3; \
    \
    # AWS stuff
    curl -fSL "https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest" -o /usr/local/bin/ecs-cli; \
    chmod +x /usr/local/bin/ecs-cli; \
    curl -fSL https://raw.githubusercontent.com/silinternational/ecs-deploy/develop/ecs-deploy -o /usr/local/bin/ecs-deploy; \
    chmod +x /usr/local/bin/ecs-deploy; \
    \
    # Dont check host keys when connecting with ssh (Git) from the docker container
    sed -i 's/#   StrictHostKeyChecking .*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config

# TODO: Unsure if this should remain enabled in JVM 11
# ENV JAVA_TOOL_OPTIONS "-Dsun.zip.disableMemoryMapping=true"

VOLUME ["/home/jenkins/"]

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
