# Jenkins slave

[master](https://github.com/capralifecycle/jenkins-slave) | [legacy](https://github.com/capralifecycle/jenkins-slave/tree/legacy)
:---: | :---:
[![Build Status](https://jenkins.capra.tv/buildStatus/icon?job=jenkins-slave/legacy)](https://jenkins.capra.tv/job/jenkins-slave/legacy/job/legacy/) | [![Build Status](https://jenkins.capra.tv/buildStatus/icon?job=jenkins-slave/master)](https://jenkins.capra.tv/job/jenkins-slave/master/job/master/)
thin docker-only image | thick multi-role image

This repository contains the Docker image for Jenkins slave used with
our Jenkins 2 setup.

This image itself is not run directly by ECS, but is run inside a wrapper
image. See https://github.com/capralifecycle/jenkins-slave-wrapper

Details about our setup is available on https://confluence.capraconsulting.no/x/uALGBQ
