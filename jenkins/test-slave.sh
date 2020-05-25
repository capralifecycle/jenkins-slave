#!/bin/sh
set -e

jenkins_uid=$(id -u jenkins)
jenkins_gid=$(id -g jenkins)

echo "Checking that jenkins UID and GID is 1000 so that the UID uses a"
echo "sensible default value and the GID matches what we run docker as"
echo "in the wrapper..."
echo "UID: $jenkins_uid"
echo "GID: $jenkins_gid"
if [ "$jenkins_uid" != "1000" ] || [ "$jenkins_gid" != "1000" ]; then
  echo "ERROR: Not equal"
  exit 1
else
  echo "OK"
fi

echo "Checking that entrypoint yields expected output..."

txt=$(/entrypoint.sh -help 2>&1 || :)
if echo "$txt" | grep -q swarm.Client; then
  echo "OK"
else
  echo "ERROR: Expected string not found. Dumping output:"
  echo "$txt"
  exit 1
fi
