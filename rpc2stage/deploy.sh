#!/bin/bash

docker buildx create --use
docker buildx inspect --bootstrap
docker run --privileged linuxkit/binfmt:v0.8

REPO=`cd ../terraform && terraform output --raw repository_url`
bash -c "`aws ecr get-login --region us-west-2 --no-include-email`"
docker buildx build --progress plain --platform linux/amd64,linux/arm64,linux/arm/v7 -t ${REPO}:latest --push .

