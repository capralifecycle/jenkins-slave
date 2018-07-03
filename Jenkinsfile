#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

def dockerImageName = '923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/slave-wrapper'

buildConfig([
  jobProperties: [
    pipelineTriggers([
      // Build a new version every night so we keep up to date with upstream changes
      cron('H H(2-6) * * *'),
    ]),
  ],
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
      img = docker.build(dockerImageName, "--cache-from $lastImageId --pull .")
    }

    def isSameImage = dockerPushCacheImage(img, lastImageId)

    stage('Test image to verify Docker-in-Docker works') {
      img.inside('--privileged') {
        sh './jenkins/test-dind.sh'
      }
    }

    if (env.BRANCH_NAME == 'master' && isSameImage) {
      echo 'No release/deploy will be made because image is the same'
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
    }
  }

  if (tagName != null) {
    askDeploy {
      dockerNode {
        // The ecs-deploy utility returns after one instance has been deployed.
        // As such it should normally not bring down this slave instance we
        // are deploying from.

        slackNotify message: "Deploying new slaves for Jenkins to ECS"
        def image = "$dockerImageName:$tagName"

        // The modern and classic slaves use the same wrapper image.

        stage('Deploy classic slaves to ECS') {
          ecsDeploy("--aws-instance-profile -r eu-central-1 -c buildtools-stable -n jenkins-slave-classic -i $image")
        }

        stage('Deploy modern slaves to ECS') {
          ecsDeploy("--aws-instance-profile -r eu-central-1 -c buildtools-stable -n jenkins-slave-modern -i $image")
        }
      }
    }
  }
}

def askDeploy(body) {
  milestone 1
  if (shouldDeploy()) {
    milestone 2
    body()
  }
}

def shouldDeploy() {
  stage('Asking to deploy') {
    try {
      slackNotify message: "Need input to deploy new Jenkins slaves to ECS: `<${env.BUILD_URL}|${env.JOB_NAME} [${env.BUILD_NUMBER}]>`"
      input(message: "Deploy to ECS?")
      return true
    } catch (ignored) {
      echo "Skipping deployment"
      return false
    }
  }
}
