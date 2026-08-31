# Résultat attendu — M5 : Modules & Git Registry

## Structure des modules
```bash
ls project/03-day2-modules/modules/
```
**Attendu :** `crypto/  key-vault-rsa/  landing-zone/  naming/  rbac/  user-role-assignment/`

## Plan avec module local
```bash
cd project/03-day2-modules/environments/dev
terraform init -backend=false
terraform plan
```
**Nombre de ressources attendu :** 10+ ressources (bases, warehouses, schémas, tags, monitors, rôles, grants)

## Source de module Git-tag

Dans une variante de root dédiée au registry :

```hcl
module "landing_zone" {
  source = "git::https://dev.azure.com/<org>/<project>/_git/terraform-modules//snowflake/landing-zone?ref=v1.0.0"
}
```

```bash
terraform init -upgrade
```
**Attendu :** Télécharge le module depuis le tag Git. `terraform init` réussit.

## Outputs du module
```bash
terraform output
```
**Attendu :**
```
raw_database_name = "DB_RAW_DEV"
curated_database_name = "DB_CURATED_DEV"
warehouse_names = {
  analytics = "WH_ANALYTICS_DEV"
  etl = "WH_ETL_DEV"
}
resource_monitor_name = "RM_BUDGET_DEV"
```

## Vérification Snowflake
```sql
SHOW DATABASES LIKE 'DB_RAW_DEV';
SHOW DATABASES LIKE 'DB_CURATED_DEV';
SHOW WAREHOUSES;
SHOW RESOURCE MONITORS LIKE 'RM_BUDGET_DEV';
```
**Attendu :** Tous les objets existent avec le suffixe `_DEV` correct.

