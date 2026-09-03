provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  authenticator     = "PROGRAMMATIC_ACCESS_TOKEN"
  token             = try(trim(file("${path.module}/../../secrets/snowflake_pat.txt"), "\n\r"), var.snowflake_token, "")
}
