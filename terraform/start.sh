#!/bin/bash

yum install -y jq docker
service docker start
usermod -a -G docker ec2-user

export CORERPC=`aws --region us-west-2 secretsmanager get-secret-value --secret-id corerpc | jq -r .SecretString`
export SFACCOUNT=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfaccount | jq -r .SecretString`
export SFUSER=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfuser | jq -r .SecretString`
export SFPRIVATEKEY=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfprivatekey | jq -r .SecretString`
export SFPRIVATEKEYPASSWORD=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfprivatekeypassword | jq -r .SecretString`
export ACCOUNTID=`aws sts get-caller-identity | jq -r .Account`

docker run -e CORERPC -e SFACCOUNT -e SFUSER -e SFPRIVATEKEY -e SFPRIVATEKEYPASSWORD ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/rpc2stage:latest