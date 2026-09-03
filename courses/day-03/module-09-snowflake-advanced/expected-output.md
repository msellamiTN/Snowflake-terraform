# Résultat attendu — M9 : Snowflake avancé (Intégration Azure)

> [<- Jour 3](../README.md) · [<- Jour 2](../../day-02/README.md) · **Module 09** · [Module suivant ->](../module-10-security-auth/lab.md)

## Storage Integration
```sql
SHOW INTEGRATIONS LIKE 'SI_AZURE_DEV';
```
**Attendu :** L'intégration `SI_AZURE_DEV` existe avec `TYPE = 'EXTERNAL_API'` et `ENABLED = true`.

## File Format
```sql
SHOW FILE FORMATS IN DATABASE DB_RAW_DEV;
```
**Attendu :** `FF_CSV_RAW` dans `DB_RAW_DEV.INGESTION` avec `TYPE = CSV`, `SKIP_HEADER = 1`.

## External Stage
```sql
SHOW STAGES IN DATABASE DB_RAW_DEV;
```
**Attendu :** `STG_AZURE_RAW` dans `DB_RAW_DEV.INGESTION` avec `URL = azure://...`, `STORAGE_INTEGRATION = SI_AZURE_DEV`.

## Locations autorisées
```sql
DESC INTEGRATION SI_AZURE_DEV;
```
**Attendu :** `STORAGE_ALLOWED_LOCATIONS` contient l'URL Azure Blob configurée.

## Terraform Plan
```bash
cd project/05-capstone/environments/dev
terraform plan
```
**Attendu :** Les ressources `snowflake_storage_integration_azure`, `snowflake_file_format`, et `snowflake_stage_external_azure` sont présentes (décommentées en mode production).

