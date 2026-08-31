# Dépannage — M9 : Snowflake avancé

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `snowflake_storage_integration_azure` échoue : `insufficient privileges` | Le rôle manque `CREATE INTEGRATION` | Utiliser le rôle `ACCOUNTADMIN` ou accorder `CREATE INTEGRATION` sur le compte |
| `azure_tenant_id` non défini | `data.azurerm_client_config` non disponible | Décommenter `data "azurerm_client_config" "current" {}` et s'assurer que le provider AzureRM est configuré |
| External stage échoue : `integration not found` | Intégration pas encore créée | Ajouter `depends_on = [snowflake_storage_integration_azure.azure_integration]` |
| `SHOW STAGES` retourne vide | Stage non appliqué | Exécuter `terraform apply` avec les ressources Azure décommentées |
| Format `storage_allowed_locations` incorrect | URL sans slash final | Utiliser `azure://<account>.blob.core.windows.net/<container>/` avec slash final |
| `Error: unsupported block type` pour stage | Version de provider trop ancienne | S'assurer que le provider Snowflake `= 2.14.0` avec `preview_features_enabled` |
| `terraform plan` montre ressources commentées | Ressources Azure encore commentées | Décommenter `data.azurerm_client_config` et les blocs storage integration |

