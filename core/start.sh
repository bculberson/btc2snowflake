#!/bin/bash

export CORERPCPASSWORD=`aws --region us-west-2 secretsmanager get-secret-value --secret-id corerpcpassword | jq -r .SecretString`
export SFACCOUNT=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfaccount | jq -r .SecretString`
export SFUSER=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfuser | jq -r .SecretString`
export SFPRIVATEKEY=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfprivatekey | jq -r .SecretString`
export ACCOUNTID=`aws sts get-caller-identity | jq -r .Account`

sleep 60
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com

docker pull ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/rpc2stage:latest
docker run  -d --network host -v /data/blocks:/data/blocks:ro -e "BTCBLOCKSHOME=/data/blocks" -e SFACCOUNT -e SFUSER -e SFPRIVATEKEY ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/rpc2stage:latest

docker pull ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/explorer:latest
docker run -d --network host -e "BTCEXP_BITCOIND_URI=bitcoin://bitcoin:${CORERPCPASSWORD}@127.0.0.1:8332?timeout=30000" -e "BTCEXP_BITCOIND_USER=bitcoin" -e "BTCEXP_BITCOIND_PASS=${CORERPCPASSWORD}" ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/explorer:latest
