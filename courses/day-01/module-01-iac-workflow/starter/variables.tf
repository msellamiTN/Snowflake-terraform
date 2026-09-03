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

  validation {
    condition     = contains(["X-SMALL", "SMALL", "MEDIUM", "LARGE", "X-LARGE"], var.warehouse_size)
    error_message = "warehouse_size must be a valid Snowflake size."
  }
}

variable "schemas" {
  type        = list(string)
  description = "Liste des schemas a creer dans DB_RAW"
  default     = ["SALES", "FINANCE"]
}

variable "data_retention_days" {
  type        = number
  description = "Jours de retention pour la database"
  default     = 1

  validation {
    condition     = var.data_retention_days >= 0 && var.data_retention_days <= 90
    error_message = "data_retention_days must be between 0 and 90 days."
  }
}
