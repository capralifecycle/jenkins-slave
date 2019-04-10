# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:18.09-dind@sha256:fa6025399dcc96d8ea04cbf1e0b325d965f85459bd22846b21a556c669c43515

RUN apk add -Uuv \
      jq \
      py2-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker

COPY container/* /

CMD ["/run.sh"]
