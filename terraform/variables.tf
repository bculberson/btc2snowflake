variable "snowflake_account" {
  type        = string
  description = "The account name for snowflake."
}

variable "snowflake_username" {
  type        = string
  description = "The username for the snowflake user (with ACCOUNTADMIN)"
}

variable "snowflake_password" {
  type        = string
  description = "The password for the snowflake user (with ACCOUNTADMIN)"
}

