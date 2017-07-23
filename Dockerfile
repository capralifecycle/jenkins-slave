# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:17.03-dind

RUN apk add -Uuv \
      py2-pip \
      supervisor \
    && pip install awscli

COPY container/* /

ENTRYPOINT ["/entrypoint.sh"]
