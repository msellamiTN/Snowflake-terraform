# Dépannage — M9 : Snowflake avancé

> [<- Jour 3](../README.md) · [<- Jour 2](../../day-02/README.md) · **Module 09** · [Module suivant ->](../module-10-security-auth/lab.md)

| Symptôme | Cause | Solution |
|----------|-------|----------|
| `snowflake_storage_integration_azure` échoue : `insufficient privileges` | Le rôle manque `CREATE INTEGRATION` | Utiliser le rôle `ACCOUNTADMIN` ou accorder `CREATE INTEGRATION` sur le compte |
| `azure_tenant_id` non défini | `data.azurerm_client_config` non disponible | Décommenter `data "azurerm_client_config" "current" {}` et s'assurer que le provider AzureRM est configuré |
| External stage échoue : `integration not found` | Intégration pas encore créée | Ajouter `depends_on = [snowflake_storage_integration_azure.azure_integration]` |
| `SHOW STAGES` retourne vide | Stage non appliqué | Exécuter `terraform apply` avec les ressources Azure décommentées |
| Format `storage_allowed_locations` incorrect | URL sans slash final | Utiliser `azure://<account>.blob.core.windows.net/<container>/` avec slash final |
| `Error: unsupported block type` pour stage | Version de provider trop ancienne | S'assurer que le provider Snowflake `= 2.14.0` avec `preview_features_enabled` |
| `terraform plan` montre ressources commentées | Ressources Azure encore commentées | Décommenter `data.azurerm_client_config` et les blocs storage integration |

---

## Execution policy PowerShell

**Symptome :**

```text
Impossible de charger le fichier ...ps1, car l'execution de scripts est desactivee.
```

**Cause :** La politique d'execution PowerShell est reglee sur `Restricted`.

**Correction :**

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

> `RemoteSigned` autorise les scripts locaux. C'est le parametre standard pour un poste de formation.

**Alternative ponctuelle :**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\<script-name>.ps1
```

