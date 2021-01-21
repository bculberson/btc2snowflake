#!/bin/bash

docker buildx create --use --name rpc2stage
docker buildx inspect --bootstrap
docker run --privileged linuxkit/binfmt:v0.8

terraform init
terraform apply

REPO=`terraform output --raw repository_url`
bash -c "`aws ecr get-login --region us-west-2 --no-include-email`"
docker buildx build --platform linux/arm64 -t ${REPO}:latest --push .




