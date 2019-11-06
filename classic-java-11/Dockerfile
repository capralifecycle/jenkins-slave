FROM azul/zulu-openjdk-alpine:11@sha256:89afccf70e550667387c09c4efc7945a76c77cb3ea0f1043d2eb4a2f49a5ac68

# py3-paramiko and py3-cffi is for docker compose installed later
# see https://github.com/docker/compose/issues/6617#issuecomment-478662098
RUN set -eux; \
    apk add --no-cache \
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
    ; \
    pip3 install awscli

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
ENV JENKINS_SWARM_VERSION 3.12

RUN set -eux; \
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
        npm \
        nodejs \
        py2-pip \
        python \
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
    # Make bash default shell
    ln -sf /bin/bash /bin/sh; \
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

VOLUME ["/home/jenkins/"]

ADD container/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
