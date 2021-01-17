# btc2snowflake

This project will be used to get the BTC blockchain in snowflake.

Donations received at https://commerce.coinbase.com/checkout/83f16545-6a9d-4cbc-970f-28cdd5a7b9fb




Add docker to core node
https://serverfault.com/questions/836198/how-to-install-docker-on-aws-ec2-instance-with-ami-ce-ee-update

Stream data to python script to upload to stage
/usr/local/bin/bitcoinetl export_blocks_and_transactions --start-block 0 --end-block 10 --provider-uri http://bitcoin:password@localhost:8332 --chain bitcoin  --blocks-output blocks.json --transactions-output transactions.json

