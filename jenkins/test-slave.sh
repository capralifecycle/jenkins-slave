#!/bin/sh
set -e

txt=$(/entrypoint.sh -help 2>&1 || :)
if echo "$txt" | grep -q swarm.Client; then
  echo "Test OK"
else
  echo "Test failed - expected string not found. Dumping output:"
  echo "$txt"
  exit 1
fi