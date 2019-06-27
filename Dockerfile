# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:18.09-dind@sha256:2e56e3035fc9e220190d3c437ea38fdf7fd4933be4715e74c155a5ee5cbcbe84

RUN apk add -Uuv \
      jq \
      py2-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker

COPY container/* /

CMD ["/run.sh"]
