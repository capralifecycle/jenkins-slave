# Jenkins slave wrapper

[![Build Status](https://jenkins.capra.tv/buildStatus/icon?job=jenkins-slave-wrapper/master)](https://jenkins.capra.tv/job/jenkins-slave-wrapper/job/master/)

This repository contains the Docker image for Jenkins slave wrapper used with
our Jenkins 2 setup.

This image is only a wrapper to provide Docker-in-Docker to the Jenkins slaves
in an isolated environment. This image runs the actualy Jenkin slave as a
container within itself.

For the actual Jenkins slave, see
https://github.com/capralifecycle/jenkins-slave

## Deploying new slaves

New slave wrapper builds must be deloyed by following the procedure for
https://github.com/capralifecycle/aws-infrastructure/tree/master/cloudformation/buildtools.

See `jenkins.yml` in that repo for the different slaves we run.
