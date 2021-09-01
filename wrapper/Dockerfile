# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:20-dind@sha256:930d9041e55d0be64f84cc1a83c75be5d0ae456732b731ee3787fbb5e1f54303

RUN apk add -Uuv \
      bash \
      jq \
      procps \
      py3-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker \
    && mkdir /home/jenkins \
    && chown 1000:1000 /home/jenkins

# Set DOCKER_HOST so that it will not be dependent on what happens in the
# docker own entrypoint script.
ENV DOCKER_HOST=unix:///var/run/docker.sock

COPY wrapper/container/* /

CMD ["/run.sh"]
