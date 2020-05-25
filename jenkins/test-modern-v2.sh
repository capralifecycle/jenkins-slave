#!/bin/bash
set -eu -o pipefail

./jenkins/test-dind.sh

su-exec jenkins ./jenkins/test-modern-v2-jenkins-user.sh

txt=$(/run-jenkins-slave.sh -help 2>&1 || :)
if echo "$txt" | grep -q swarm.Client; then
  echo "Test OK"
else
  echo "Test failed - expected string not found. Dumping output:"
  echo "$txt"
  exit 1
fi
