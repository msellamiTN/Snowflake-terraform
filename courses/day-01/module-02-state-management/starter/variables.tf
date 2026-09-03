variable "snowflake_organization" {
  type        = string
  description = "Snowflake organization name"
}

variable "snowflake_account" {
  type        = string
  description = "Snowflake account name (not locator)"
}

variable "snowflake_user" {
  type        = string
  description = "Service user for Terraform"
  default     = "TERRAFORM_SVC"
}

variable "snowflake_role" {
  type        = string
  description = "Role used by Terraform"
  default     = "ACCOUNTADMIN"
}

variable "snowflake_token" {
  type        = string
  description = "Snowflake PAT (optional - read from secrets/snowflake_pat.txt if not set)"
  sensitive   = true
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment suffix (DEV, TEST, PROD)"
  default     = "DEV"

  validation {
    condition     = contains(["DEV", "TEST", "PROD"], var.environment)
    error_message = "environment must be DEV, TEST, or PROD."
  }
}

variable "project" {
  type        = string
  description = "Project prefix for naming"
  default     = "DATAPLATFORM"
}

variable "warehouse_size" {
  type        = string
  description = "Default warehouse size"
  default     = "X-SMALL"
}

variable "schemas" {
  type        = list(string)
  description = "Business schemas to create in RAW database"
  default     = ["SALES", "FINANCE"]
}
