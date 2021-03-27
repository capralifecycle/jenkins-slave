#!/bin/sh
set -eu

while true; do
  # Run every hour.
  sleep 3600
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

  # Remove images created for more than X hours ago.
  # The time limit is an attempt to keep some images in
  # cache over a longer time.
  # TODO: Increase this in later setup. See CALS-294 for background.
  docker image prune --force --all --filter until=18h

  echo "Cleanup complete"
  date
done
