#!/bin/bash

docker buildx create --use --name rpc2stage
docker buildx inspect --bootstrap
docker run --privileged linuxkit/binfmt:v0.8

terraform init
terraform apply

REPO=`terraform output --raw repository_url`
ACCOUNTID=`aws sts get-caller-identity | jq -r .Account`
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com
docker buildx build --platform linux/amd64 -t ${REPO}:latest --push .




