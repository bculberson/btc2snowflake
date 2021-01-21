#!/bin/bash

export CORERPC=`aws --region us-west-2 secretsmanager get-secret-value --secret-id corerpc | jq -r .SecretString`
export SFACCOUNT=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfaccount | jq -r .SecretString`
export SFUSER=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfuser | jq -r .SecretString`
export SFPRIVATEKEY=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfprivatekey | jq -r .SecretString`
export ACCOUNTID=`aws sts get-caller-identity | jq -r .Account`

sleep 60
bash -c "`aws ecr get-login --region us-west-2 --no-include-email`"
docker run -e CORERPC -e SFACCOUNT -e SFUSER -e SFPRIVATEKEY -e "FLUSH_SIZE=1000000" ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/rpc2stage:latest
