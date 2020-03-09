# Jenkins slaves

[![Build Status](https://jenkins.capra.tv/buildStatus/icon?job=buildtools/jenkins-slave/master)](https://jenkins.capra.tv/job/buildtools/job/jenkins-slave/job/master/)

This repository contains the Docker images for our Jenkins slaves used with
our Jenkins setup.

We use the [Swarm](https://plugins.jenkins.io/swarm/) plugin so that
slaves register to the master when they are brought up in the cluster.

Internal details about our setup is available on
https://confluence.capraconsulting.no/x/uALGBQ

## Wrapper setup

The slave images using this setup does not run directly on ECS, but runs
within a wrapper image, as can be seen in the [wrapper](./wrapper/)
directory. The wrapper container then runs Docker-in-Docker and will
spinn up the slave itself as one of its containers.

### Slave versions

* *Modern slave*: Thin slave supposed to only have Docker. Builds use Docker
  to provide a self-defined build context and tooling.

* *Classic slave*: Thick slave supporting classic freestyle jobs that do not
  use Docker to provide tooling. Contains JDK, node and more tooling.

* *Classic slave for Java 11*: Thick slave supporting classic freestyle jobs
  for Java 11. Contains JDK, node and more tooling. This is considered only
  temporary until either the two classic slaves are merged or we have switch
  to using the modern slaves/builds.

## Direct setup

The slave images using this setup runs directly on ECS, so that
both the Docker daemon and Swarm application is running in the
same environment.

This allows builds to volume mount files and directories, which
does not properly work in the wrapper setup.

### Slave versions

* *Modern v2 slave*: Thin slave supposed to only have Docker. Builds use
  Docker to provide a self-defined build context and tooling.

## Deploying new slaves

New slave wrapper builds must be deloyed by following the procedure for
https://github.com/capralifecycle/aws-infrastructure/tree/master/buildtools.

See `jenkins.yml` in that repo for the different slaves we run.
