# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:19-dind@sha256:ecb51f5e1184ffe5c33dbb316b7ce13784807a8b209302ebb25b4ffbf4c51e1f

RUN apk add -Uuv \
      jq \
      py2-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker

# Set DOCKER_HOST so that it will not be dependent on what happens in the
# docker own entrypoint script.
ENV DOCKER_HOST=unix:///var/run/docker.sock

COPY wrapper/container/* /

CMD ["/run.sh"]
