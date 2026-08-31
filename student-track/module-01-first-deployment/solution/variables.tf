variable "snowflake_profile" {
  type        = string
  description = "Snowflake CLI profile configured during Module 00"
  default     = "terraform_svc"
}

variable "learner_prefix" {
  type        = string
  description = "Unique uppercase prefix assigned to the learner"

  validation {
    condition     = can(regex("^[A-Z][A-Z0-9_]{1,11}$", var.learner_prefix))
    error_message = "learner_prefix must contain 2-12 uppercase letters, digits, or underscores."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "DEV"

  validation {
    condition     = contains(["DEV", "TEST"], var.environment)
    error_message = "environment must be DEV or TEST."
  }
}

variable "warehouse_size" {
  type        = string
  description = "Training warehouse size"
  default     = "X-SMALL"

  validation {
    condition     = contains(["X-SMALL", "SMALL"], var.warehouse_size)
    error_message = "Training warehouses must be X-SMALL or SMALL."
  }
}
