# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:18.09-dind@sha256:7db75fcec4a37f16e3a92e5e1b650e0a17b438d59f4f1c9ad8c6c5f287e958e0

RUN apk add -Uuv \
      jq \
      py2-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker

COPY container/* /

CMD ["/run.sh"]
