#!/bin/bash

terraform init

# create dependencies for build process
terraform apply --target aws_s3_bucket.data

BUCKET=`terraform output --raw startup_script_bucket`
aws s3 ls s3://${BUCKET}/bitcoin-0.21.0-aarch64-linux-gnu.tar.gz
if [ $? -ne 0 ]; then
  curl -o bitcoin-0.21.0-aarch64-linux-gnu.tar.gz https://bitcoin.org/bin/bitcoin-core-0.21.0/bitcoin-0.21.0-aarch64-linux-gnu.tar.gz
  aws s3 cp bitcoin-0.21.0-aarch64-linux-gnu.tar.gz s3://${BUCKET}/bitcoin-0.21.0-aarch64-linux-gnu.tar.gz
fi

terraform apply
