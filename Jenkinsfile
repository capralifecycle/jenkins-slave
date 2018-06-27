#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

buildConfig([
  jobProperties: [
    pipelineTriggers([
      // Build a new version every night so we keep up to date with upstream changes
      cron('H H(2-6) * * *'),
    ]),
  ],
  githubUrl: 'https://github.com/capralifecycle/jenkins-slave/',
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
      build('classic', 'classic')
    },
  )
}

def build(name, rollingTag) {
  def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/slave'

  dockerNode {
    stage('Checkout source') {
      checkout scm
    }

    def img
    def lastImageId = dockerPullCacheImage(dockerImageName, name)

    stage('Build Docker image') {
      img = docker.build(dockerImageName, "--cache-from $dockerImageName:$lastImageId --pull -f ./$name/Dockerfile .")
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
        def tagName = sh([
          returnStdout: true,
          script: 'date +%Y%m%d-%H%M'
        ]).trim() + "-$name-${env.BUILD_NUMBER}"

        img.push(tagName)
        img.push(rollingTag)

        slackNotify message: "New Docker image available: $dockerImageName:$tagName"
      }
    }
  }
}
