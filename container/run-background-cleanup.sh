#!/bin/sh
set -eu

while true; do
  sleep 43200
  date
  echo "Running cleanup script"

  # We are not using `docker system prune` because we
  # want to target a different filter for the image pruning.

  # Remove all stopped containers.
  docker container prune --force

  # Remove all unused volumes.
  docker volume prune --force

  # Remove all unused networks.
  docker network prune --force --filter until=1h

  # Remove images created for more than 3 days ago.
  # The time limit is an attempt to keep some images in
  # cache over a longer time.
  docker image prune --force --all --filter until=72h

  echo "Cleanup complete"
  date
done
