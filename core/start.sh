#!/bin/bash

export CORERPCPASSWORD=`aws --region us-west-2 secretsmanager get-secret-value --secret-id corerpcpassword | jq -r .SecretString`
export SFACCOUNT=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfaccount | jq -r .SecretString`
export SFUSER=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfuser | jq -r .SecretString`
export SFPRIVATEKEY=`aws --region us-west-2 secretsmanager get-secret-value --secret-id sfprivatekey | jq -r .SecretString`
export ACCOUNTID=`aws sts get-caller-identity | jq -r .Account`

sleep 60
bash -c "`aws ecr get-login --region us-west-2 --no-include-email`"
docker pull ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/rpc2stage:latest
docker run -d --network host -e "CORERPC=http://bitcoin:${CORERPCPASSWORD}@localhost:8332" -e SFACCOUNT -e SFUSER -e SFPRIVATEKEY -e "FLUSH_SIZE=1000000" ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/rpc2stage:latest
docker pull ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/explorer:latest
docker run -d --network host -e "BTCEXP_BITCOIND_USER=bitcoin" -e "BTCEXP_BITCOIND_PASS=${CORERPCPASSWORD}" ${ACCOUNTID}.dkr.ecr.us-west-2.amazonaws.com/explorer:latest
