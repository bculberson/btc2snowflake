# btc2snowflake

This project can be used to get the BTC blockchain in Snowflake.

Donations received online at https://commerce.coinbase.com/checkout/83f16545-6a9d-4cbc-970f-28cdd5a7b9fb

or direct:

    bitcoin:bc1que4ks2m3hm874swquqmcmzx2zy5m5qvyt0gdma

    eth:0xD1C3c13277eA22eBED0Aef19C1b4B001d81f1433

How to start:

```shell
pushd terraform && terraform apply --target aws_ecr_repository.rpc2stage && popd
pushd ../rpc2stage && ./deploy.sh && popd
pushd terraform && terraform apply
```

examples of json from blockchain:

```json
{
  "type":"transaction",
  "hash":"aa8628f83ff173c29006a75e344dc0b1bbad9a3cd02f33343d9a3581ae52f268",
  "size":135,
  "virtual_size":135,
  "version":1,
  "lock_time":0,
  "block_number":474,
  "block_hash":"000000000d15d5f0d9971ab61c06e59f2e63e4a9cfbbb79d8f2b9d32243ee540",
  "block_timestamp":1231950841,
  "is_coinbase":true,
  "index":0,
  "inputs":[

  ],
  "outputs":[
    {
      "index":0,
      "script_asm":"04e590d7adbfbfa8b320ef2d412c8cb5967af9f7e3058fdebe454b0c2f743009021265beb10c635a31d7cd803c249d0c6a582cad05b3f41148a30a99fc21bf42d8 OP_CHECKSIG",
      "script_hex":"4104e590d7adbfbfa8b320ef2d412c8cb5967af9f7e3058fdebe454b0c2f743009021265beb10c635a31d7cd803c249d0c6a582cad05b3f41148a30a99fc21bf42d8ac",
      "required_signatures":null,
      "type":"nonstandard",
      "addresses":[
        "nonstandard632ed460099d8a5de1473fa7965f4fcaaca59bb6"
      ],
      "value":5000000000
    }
  ],
  "input_count":0,
  "output_count":1,
  "input_value":0,
  "output_value":5000000000,
  "fee":0,
  "item_id":"transaction_aa8628f83ff173c29006a75e344dc0b1bbad9a3cd02f33343d9a3581ae52f268"
}
```

```json

{
  "type":"block",
  "hash":"00000000fd3546b2d219faa87a34e1e6593769d753cf86fc647c4ee2a07710d1",
  "size":216,
  "stripped_size":216,
  "weight":864,
  "number":470,
  "version":1,
  "merkle_root":"8def47739d3cedc44c4cb8fa229f81445888eacd062ce31f28cbdf1aab52cba1",
  "timestamp":1231948637,
  "nonce":"bc071e18",
  "bits":"1d00ffff",
  "coinbase_param":"04ffff001d02f903",
  "transaction_count":1,
  "item_id":"block_00000000fd3546b2d219faa87a34e1e6593769d753cf86fc647c4ee2a07710d1"
}

```

TODO:

Create task to load data from stage, and transform to transactions and blocks.
