# Jenkins slave with Docker setup
#
# This image runs a Docker daemon as well as the Jenkins slave.
#
# To simplify the setup and later maintenance we compose the services
# so that the actual Jenkins slave is a container within this container.
#

FROM docker:18.09-dind@sha256:91ab5a9e80c1eb42fd9160aa4cbafad21763311de609496d4209235f26945e1c

RUN apk add -Uuv \
      jq \
      py2-pip \
      supervisor \
    && pip install awscli \
    && addgroup docker

COPY container/* /

CMD ["/run.sh"]
