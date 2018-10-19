# Jenkins slaves

[![Build Status](https://jenkins.capra.tv/buildStatus/icon?job=jenkins-slave/master)](https://jenkins.capra.tv/job/jenkins-slave/job/master/)

This repository contains the Docker images for our Jenkins slaves used with
our Jenkins 2 setup.

This image itself is not run directly on ECS, but is run inside a wrapper
image. See https://github.com/capralifecycle/jenkins-slave-wrapper

Details about our setup is available on https://confluence.capraconsulting.no/x/uALGBQ

## Slave versions

We build to different slaves:

* *Modern slave*: Thin slave supposed to only have Docker. Builds use Docker
  to provide a self-defined build context and tooling.

* *Classic slave*: Thick slave supporting classic freestyle jobs that do not
  use Docker to provide tooling. Contains JDK, node and more tooling.

* *Classic slave for Java 11*: Thick slave supporting classic freestyle jobs
  for Java 11. Contains JDK, node and more tooling. This is considered only
  temporary until either the two classic slaves are merged or we have switch
  to using the modern slaves/builds.
