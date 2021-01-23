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

variable "snapshot" {
  type        = string
  description = "The snapshot_id for a bitcoin data volume"
  default     = "none"
}

variable "instance_type" {
  type        = string
  description = "The instance_type for the core server"
  default     = "t3a.medium"
}
