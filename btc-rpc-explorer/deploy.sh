#!/bin/bash

terraform init
terraform apply

REPO=`terraform output --raw repository_url`
ACCOUNTID=`aws sts get-caller-identity | jq -r .Account`
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com
docker build -t ${REPO}:latest .
docker push ${REPO}:latest
