output "resource_group_name" {
  value       = azurerm_resource_group.state.name
  description = "Resource group for remote Terraform state"
}

output "storage_account_name" {
  value       = azurerm_storage_account.state.name
  description = "Storage account for remote Terraform state"
}

output "container_name" {
  value       = azurerm_storage_container.state.name
  description = "Storage container for remote Terraform state"
}

output "storage_account_id" {
  value       = azurerm_storage_account.state.id
  description = "Resource ID of the storage account (for RBAC assignments)"
}

output "backend_config_snippet" {
  value       = <<-EOT
    # Paste into backend.tf and replace <team> and <environment>
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.state.name}"
        storage_account_name = "${azurerm_storage_account.state.name}"
        container_name       = "${azurerm_storage_container.state.name}"
        key                  = "training/<team>/<environment>/<module>.tfstate"
      }
    }
  EOT
  description = "Backend configuration template. Replace <team>, <environment>, and <module> with your values."
}

output "backend_hcl_snippet" {
  value       = <<-EOT
    # Save as backend.hcl (gitignored) and use: terraform init -backend-config=backend.hcl
    resource_group_name  = "${azurerm_resource_group.state.name}"
    storage_account_name = "${azurerm_storage_account.state.name}"
    container_name       = "${azurerm_storage_container.state.name}"
    key                  = "training/<team>/<environment>/<module>.tfstate"
  EOT
  description = "Partial backend configuration for terraform init -backend-config=backend.hcl"
}

output "key_vault_name" {
  value       = azurerm_key_vault.secrets.name
  description = "Name of the Azure Key Vault storing all secrets"
}

output "key_vault_id" {
  value       = azurerm_key_vault.secrets.id
  description = "Resource ID of the Azure Key Vault"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.secrets.vault_uri
  description = "URI of the Azure Key Vault (for Azure DevOps service connection)"
}

output "key_vault_secret_names" {
  value = {
    snowflake_organization = "SnowflakeOrganization"
    snowflake_account      = "SnowflakeAccount"
    snowflake_user         = "SnowflakeUser"
    snowflake_role         = "SnowflakeRole"
    snowflake_password     = "SnowflakePassword"
    arm_client_id          = "ArmClientId"
    arm_client_secret      = "ArmClientSecret"
    arm_tenant_id          = "ArmTenantId"
    arm_subscription_id    = "ArmSubscriptionId"
  }
  description = "Map of secret names stored in Key Vault (for Azure DevOps variable group mapping)"
}
