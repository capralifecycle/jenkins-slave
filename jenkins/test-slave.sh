#!/bin/sh
set -e

./jenkins/test-slave-expectations.sh

echo "Checking that entrypoint yields expected output..."

txt=$(/entrypoint.sh -help 2>&1 || :)
if echo "$txt" | grep -q swarm.Client; then
  echo "OK"
else
  echo "ERROR: Expected string not found. Dumping output:"
  echo "$txt"
  exit 1
fi
