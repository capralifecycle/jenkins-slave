#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

def jobProperties = []

if (env.BRANCH_NAME == 'master') {
  jobProperties << pipelineTriggers([
    // Build a new version every night so we keep up to date with upstream changes
    cron('H H(2-6) * * *'),
  ])
}

buildConfig([
  jobProperties: jobProperties,
  slack: [
    channel: '#cals-dev-info',
    teamDomain: 'cals-capra',
  ],
]) {
  parallel (
    'modern': {
      build('modern', 'latest')
    },
    'classic': {
      build('classic')
    },
    // TODO: This is only a temporary solution to get quick Java 11 support.
    // We want to either have Java 8 and Java 11 in the same classic slave,
    // or make a improved Jenkinsfile to support our flows.
    // See https://github.com/capralifecycle/buildtools-example-java-2
    'classic-java-11': {
      build('classic-java-11')
    },
  )
}

def build(name, additionalTag = null) {
  def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-slave'

  dockerNode {
    stage('Checkout source') {
      checkout scm
    }

    def img
    def tagName = sh([
      returnStdout: true,
      script: 'date +%Y%m%d-%H%M'
    ]).trim() + "-$name-${env.BUILD_NUMBER}"
    def lastImageId = dockerPullCacheImage(dockerImageName, name)

    stage('Build Docker image') {
      img = docker.build("$dockerImageName:$tagName", "--cache-from $lastImageId --pull -f ./$name/Dockerfile .")
    }

    stage('Test image to verify build') {
      // We need to force the container to run as root so that the entrypoint
      // will work correctly.
      img.inside('-u root') {
        sh './jenkins/test-image.sh'
      }
    }

    def isSameImage = dockerPushCacheImage(img, lastImageId, name)

    if (env.BRANCH_NAME == 'master' && !isSameImage) {
      stage('Push Docker image') {
        img.push(tagName)
        img.push(name)

        if (additionalTag != null) {
          img.push(additionalTag)
        }

        slackNotify message: "New Docker image available: $dockerImageName:$tagName"
      }
    }
  }
}
