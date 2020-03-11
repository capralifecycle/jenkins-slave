# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:19-dind@sha256:0e6d34042007a6f5280838dc045af0d600654b57cd367251d1dd8bba4b55c773

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
