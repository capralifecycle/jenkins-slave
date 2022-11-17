# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:20-dind@sha256:80e81aecd51d80e63ae4cbbd5eb1968e84edd151b90ef2c2f17e1004c7a3832b

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
