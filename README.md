# Jenkins slave wrapper

This repository contains the Docker image for Jenkins slave wrapper used with
our Jenkins 2 setup.

This image is only a wrapper to provide Docker-in-Docker to the Jenkins slaves
in an isolated environment. This image runs the actualy Jenkin slave as a
container within itself.

For the actual Jenkins slave, see
https://github.com/capralifecycle/jenkins-slave
