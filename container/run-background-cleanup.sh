#!/bin/sh
set -eu

while true; do
  sleep 43200
  date
  echo "Running cleanup script"

  # Remove all stopped containers.
  docker container prune --force

  # Remove all unused volumes.
  docker volume prune --force

  # Remove images created for more than 3 days ago.
  # The time limit is an attempt to keep some images in
  # cache over a longer time.
  docker image prune --force --all --filter until=72h

  echo "Cleanup complete"
  date
done
