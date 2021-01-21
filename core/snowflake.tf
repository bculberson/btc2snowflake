terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.22.0"
    }
  }
}

provider "snowflake" {
  username = var.snowflake_username
  account  = var.snowflake_account
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}

resource "snowflake_database" "db" {
  name = "BTC"
}

resource "snowflake_role" "dml_role" {
  name = "DML_BTC"
}

resource "snowflake_database_grant" "grant" {
  database_name = snowflake_database.db.name

  privilege = "USAGE"
  roles     = [snowflake_role.dml_role.name]

  with_grant_option = false
}

resource "snowflake_schema" "schema" {
  database = snowflake_database.db.name
  name     = "BTC"

  is_managed = false
}

resource "snowflake_schema_grant" "grant" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name

  privilege = "USAGE"
  roles     = [snowflake_role.dml_role.name]

  with_grant_option = false
}

resource "snowflake_stage" "stage" {
  name     = "btc_stage"
  database = snowflake_database.db.name
  schema   = snowflake_schema.schema.name
}

resource "snowflake_stage_grant" "grant_read" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  stage_name    = snowflake_stage.stage.name

  privilege = "READ"

  roles = ["ACCOUNTADMIN", snowflake_role.dml_role.name]

  with_grant_option = false
}

resource "snowflake_stage_grant" "grant_write" {
  database_name = snowflake_database.db.name
  schema_name   = snowflake_schema.schema.name
  stage_name    = snowflake_stage.stage.name

  privilege = "WRITE"

  roles = ["ACCOUNTADMIN", snowflake_role.dml_role.name]

  with_grant_option = false
}


resource "snowflake_table" "table" {
  database = snowflake_database.db.name
  schema   = snowflake_schema.schema.name
  name     = "btc_blockchain_raw"

  column {
    name = "src"
    type = "VARIANT"
  }
}

resource "snowflake_warehouse" "warehouse" {
  name           = "BTC"
  warehouse_size = "xsmall"

  auto_suspend = 60
}

resource "snowflake_warehouse_grant" "grant" {
  warehouse_name = "BTC"
  privilege      = "USAGE"

  roles = [snowflake_role.dml_role.name]

  with_grant_option = false
}

resource "tls_private_key" "svc_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "snowflake_user" "user" {
  name = "btc_svc"

  default_warehouse = snowflake_warehouse.warehouse.name
  default_role      = snowflake_role.dml_role.name
  default_namespace = "${snowflake_database.db.name}.${snowflake_schema.schema.name}"
  rsa_public_key    = substr(tls_private_key.svc_key.public_key_pem, 27, 398)

}
