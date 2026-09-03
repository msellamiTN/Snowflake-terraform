# Provider Snowflake
#
# The PAT is read from secrets/snowflake_pat.txt (created by New-SnowflakeConnection.ps1).
# This file is at the project root. From labs/mXX-name/, the path is ../../secrets/.
#
# If the file doesn't exist, it falls back to TF_VAR_snowflake_token env var.
# The learner never needs to type the PAT manually.

locals {
  # Path to the PAT file, relative to this Terraform module.
  # labs/mXX-name/ -> ../../ = project root
  pat_file = "${path.module}/../../secrets/snowflake_pat.txt"

  # Read the PAT from the file if it exists, otherwise use the env var.
  snowflake_token = try(trim(file(local.pat_file), "\n\r"), var.snowflake_token, "")
}

provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  authenticator     = "PROGRAMMATIC_ACCESS_TOKEN"
  token             = local.snowflake_token
}
