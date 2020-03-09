#!/usr/bin/env groovy

// See https://github.com/capralifecycle/jenkins-pipeline-library
@Library('cals') _

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
  parallel (
    'modern': {
      buildWrappedSlave('modern', 'latest')
    },
    'modern-v2': {
      buildDockerImage(
        "923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-slave",
        "modern-v2",
        null,
        "./modern-v2/Dockerfile"
      ) { img ->
        stage('Test image') {
          img.inside('--privileged --user root') {
            sh 'IS_TEST=1 ./jenkins/test-modern-v2.sh'
          }
        }
      }
    },
    'classic': {
      buildWrappedSlave('classic')
    },
    // TODO: This is only a temporary solution to get quick Java 11 support.
    // We want to either have Java 8 and Java 11 in the same classic slave,
    // or make a improved Jenkinsfile to support our flows.
    // See https://github.com/capralifecycle/buildtools-example-java-2
    'classic-java-11': {
      buildWrappedSlave('classic-java-11')
    },
    'wrapper': {
      buildDockerImage(
        "923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-slave-wrapper",
        "latest",
        null,
        "./wrapper/Dockerfile"
      ) { img ->
        stage('Test image to verify Docker-in-Docker works') {
          img.inside('--privileged --user root') {
            sh './jenkins/test-dind.sh'
          }
        }
      }
    },
  )
}

def buildWrappedSlave(name, additionalTag = null) {
  buildDockerImage(
    "923402097046.dkr.ecr.eu-central-1.amazonaws.com/buildtools/service/jenkins-slave",
    name,
    additionalTag,
    "./$name/Dockerfile"
  ) { img ->
    stage('Test image to verify build') {
      // We need to force the container to run as root so that the entrypoint
      // will work correctly.
      img.inside('-u root') {
        sh './jenkins/test-slave.sh'
      }
    }
  }
}

def buildDockerImage(
  dockerImageName,
  name,
  additionalTag,
  dockerfile,
  testImage
) {
  dockerNode {
    stage('Checkout source') {
      checkout scm
    }

    def cacheSuffix = name == "latest" ? null : name
    def tagExtra = name == "latest" ? "" : "-$name"

    def img
    def tagName = sh([
      returnStdout: true,
      script: 'date +%Y%m%d-%H%M%S'
    ]).trim() + "$tagExtra-" + env.BUILD_NUMBER

    def lastImageId = dockerPullCacheImage(dockerImageName, cacheSuffix)

    stage('Build Docker image') {
      def args = ""
      if (params.docker_skip_cache) {
        args = " --no-cache"
      }

      img = docker.build("$dockerImageName:$tagName", "--cache-from $lastImageId$args --pull -f $dockerfile .")
    }

    testImage(img)

    def isSameImage = dockerPushCacheImage(img, lastImageId, cacheSuffix)

    if (env.BRANCH_NAME == 'master' && !isSameImage) {
      stage('Push Docker image') {
        img.push(tagName)
        img.push(name)

        if (additionalTag != null) {
          img.push(additionalTag)
        }
      }

      slackNotify message: "New Docker image available: $dockerImageName:$tagName"
    }
  }
}
