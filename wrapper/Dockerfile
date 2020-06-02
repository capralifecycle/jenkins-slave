# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:19-dind@sha256:3ab0c1503c6ccc9e4d8f3ee1a605ec05f4e49335a5f12ec1f617e4f387a7a53e

RUN apk add -Uuv \
      jq \
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
