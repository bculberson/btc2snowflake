#!/bin/bash

docker buildx create --use --name explorer
docker buildx inspect --bootstrap
docker run --privileged linuxkit/binfmt:v0.8

terraform init
terraform apply

REPO=`terraform output --raw repository_url`
bash -c "`aws ecr get-login --region us-west-2 --no-include-email`"
docker buildx build --platform linux/amd64,linux/arm64 -t ${REPO}:latest --push .




