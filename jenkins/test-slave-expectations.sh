#!/bin/sh
# This file is used to verify that all our slaves adhere to some common
# setup so that jobs works as expected.
set -e

jenkins_uid=$(id -u jenkins)
jenkins_gid=$(id -g jenkins)

echo "Checking that jenkins UID and GID is 1000 so that the UID uses a"
echo "sensible default value and the GID matches what we run docker."
echo "UID: $jenkins_uid"
echo "GID: $jenkins_gid"
if [ "$jenkins_uid" != "1000" ] || [ "$jenkins_gid" != "1000" ]; then
  echo "ERROR: Not equal"
  exit 1
else
  echo "OK"
fi
