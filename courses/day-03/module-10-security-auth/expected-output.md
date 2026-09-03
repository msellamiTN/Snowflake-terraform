# Résultat attendu — M10 : Sécurité & Authentification

> [<- Jour 3](../README.md) · [<- Module precedent](../module-09-snowflake-advanced/lab.md) · **Module 10** · [Jour 4 ->](../../day-04/README.md)

## Module Key Vault
```bash
cd project/05-capstone/environments/dev
terraform plan -var="deployment_mode=production"
```
**Attendu :** Les ressources `azurerm_key_vault`, `azurerm_key_vault_secret`, `tls_private_key` dans le plan.

## Propriétés du Key Vault
| Propriété | Valeur attendue |
|-----------|-----------------|
| `sku_name` | `standard` |
| `soft_delete_retention_days` | `30` |
| `purge_protection_enabled` | `true` |
| `enable_rbac_authorization` | `true` |

## Utilisateur Snowflake avec clé RSA
```sql
DESC USER SVC_DEV_DATA_ENG;
```
**Attendu :** `RSA_PUBLIC_KEY` défini, `RSA_PUBLIC_KEY_2` vide (ou défini si rotation activée).

## Provider aliases
```bash
terraform providers
```
**Attendu :** 4 configurations du provider Snowflake :
- `provider["snowflakedb/snowflake"]` (défaut, `var.snowflake_role`)
- `provider["snowflakedb/snowflake"].sysadmin`
- `provider["snowflakedb/snowflake"].useradmin`
- `provider["snowflakedb/snowflake"].securityadmin`

## Rotation de clé (si activée)
```bash
terraform output next_secret_id
```
**Attendu :** ID de secret non-null pour la clé suivante.

## Aucune clé privée dans les outputs
```bash
terraform output | grep -i private
```
**Attendu :** Aucun matériel de clé privée dans les outputs. Uniquement des références de secret.

