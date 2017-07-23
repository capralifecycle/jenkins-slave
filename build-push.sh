#!/bin/bash
set -ex

tag=$(date +%Y%m%d-%H%M)
image=923402097046.dkr.ecr.eu-central-1.amazonaws.com/jenkins2/slave:$tag

docker build --pull -t $image .
docker push $image
