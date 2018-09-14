#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-slave-wrapper'

def jobProperties = [
  parameters([
    // Add parameter so we can build without using cached image layers.
    // This forces plugins to be reinstalled to their latest version.
    booleanParam(
      defaultValue: false,
      description: 'Force build without Docker cache',
      name: 'docker_skip_cache'
    ),
  ]),
]

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
  def tagName

  dockerNode {
    stage('Checkout source') {
      checkout scm
    }

    def img
    def lastImageId = dockerPullCacheImage(dockerImageName)

    stage('Build Docker image') {
      def args = ""
      if (params.docker_skip_cache) {
        args = " --no-cache"
      }
      img = docker.build(dockerImageName, "--cache-from $lastImageId$args --pull .")
    }

    def isSameImage = dockerPushCacheImage(img, lastImageId)

    stage('Test image to verify Docker-in-Docker works') {
      img.inside('--privileged') {
        sh './jenkins/test-dind.sh'
      }
    }

    if (env.BRANCH_NAME == 'master' && isSameImage) {
      echo 'No release will be made because image is the same as earlier build'
    }

    if (env.BRANCH_NAME == 'master' && !isSameImage) {
      tagName = sh([
        returnStdout: true,
        script: 'date +%Y%m%d-%H%M'
      ]).trim() + '-' + env.BUILD_NUMBER

      stage('Push Docker image for release') {
        img.push(tagName)
        img.push('latest')
      }

      slackNotify message: "New Jenkins slave wrapper image available: $tagName"
    }
  }
}
