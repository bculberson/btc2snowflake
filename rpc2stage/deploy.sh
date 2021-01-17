#!/bin/bash

REPO=`cd ../terraform && terraform output --raw repository_url`
bash -c "`aws ecr get-login --region us-west-2 --no-include-email`"
docker build -t ${REPO} .
docker push ${REPO}:latest

