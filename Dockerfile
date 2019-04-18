# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:18.09-dind@sha256:dcbafac80475958b3fe827aff5a71f89e10bc616b6a769e7ce87d1220b5ce169

RUN apk add -Uuv \
      jq \
      py2-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker

COPY container/* /

CMD ["/run.sh"]
