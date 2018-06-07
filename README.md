# Jenkins slave wrapper

[![Build Status](https://jenkins.capra.tv/buildStatus/icon?job=jenkins-slave-wrapper/master)](https://jenkins.capra.tv/job/jenkins-slave-wrapper/master)

This repository contains the Docker image for Jenkins slave wrapper used with
our Jenkins 2 setup.

This image is only a wrapper to provide Docker-in-Docker to the Jenkins slaves
in an isolated environment. This image runs the actualy Jenkin slave as a
container within itself.

For the actual Jenkins slave, see
https://github.com/capralifecycle/jenkins-slave

## Deploying new slaves

We automatically deploy new slaves when a build succeeds. If a faulty
slave is being deployed, no slaves might be available in Jenkins.
A manual deploy can be done through AWS console and ECS, e.g. by
using a previous task definition.
